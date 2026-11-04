# EduPlan assignments CRUD.
#
# Based directly on the professor's notes.py pattern:
# - JWT authentication
# - CRUD
# - pagination
# - server-side search
# - validation
# - standard errors
# - per-user ownership

from typing import Optional

from fastapi import APIRouter, Depends, Request, Response

from .auth import require_auth
from .db import conn, now_iso
from .errors import (
    json_response,
    not_found,
    read_json_body,
    string_field,
    validation_error,
)

router = APIRouter()


def _to_json(row) -> dict:
    return {
        "id": row["id"],
        "courseId": row["course_id"],
        "title": row["title"],
        "deadline": row["deadline"],
        "status": row["status"],
        "priority": row["priority"],
    }


def _find(user_id: int, id_param: str):
    """
    Find an assignment only among the current user's assignments.
    """
    try:
        assignment_id = int(id_param)
    except (TypeError, ValueError):
        return None

    return conn.execute(
        """
        SELECT *
        FROM assignments
        WHERE id = ? AND user_id = ?
        """,
        (
            assignment_id,
            user_id,
        ),
    ).fetchone()


def _find_course(
    user_id: int,
    course_id: int,
):
    """
    Course must belong to the same authenticated user.
    """
    return conn.execute(
        """
        SELECT *
        FROM courses
        WHERE id = ? AND user_id = ?
        """,
        (
            course_id,
            user_id,
        ),
    ).fetchone()


def _int_or(
    value: Optional[str],
    default: int,
) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _course_id_field(body) -> int:
    value = body.get("courseId")

    if (
        not isinstance(value, int)
        or isinstance(value, bool)
        or value <= 0
    ):
        raise validation_error(
            "courseId is required"
        )

    return value


def _read_fields(
    body,
    user_id: int,
):
    course_id = _course_id_field(body)

    course = _find_course(
        user_id,
        course_id,
    )

    if course is None:
        raise validation_error(
            "courseId does not reference an existing course"
        )

    title = string_field(
        body,
        "title",
    )

    deadline = string_field(
        body,
        "deadline",
    )

    status = string_field(
        body,
        "status",
    )

    priority = string_field(
        body,
        "priority",
    )

    if title is None:
        raise validation_error(
            "title is required"
        )

    if deadline is None:
        raise validation_error(
            "deadline is required"
        )

    if status is None:
        raise validation_error(
            "status is required"
        )

    if priority is None:
        raise validation_error(
            "priority is required"
        )

    allowed_statuses = {
        "New",
        "In progress",
        "Completed",
    }

    if status not in allowed_statuses:
        raise validation_error(
            "status is invalid"
        )

    allowed_priorities = {
        "Low",
        "Medium",
        "High",
    }

    if priority not in allowed_priorities:
        raise validation_error(
            "priority is invalid"
        )

    return (
        course_id,
        title,
        deadline,
        status,
        priority,
    )


@router.get("/assignments")
async def list_assignments(
    request: Request,
    user_id: int = Depends(require_auth),
):
    """
    GET /assignments?page=1&limit=20&search=
    -> {items, page, limit, total}
    """
    query = request.query_params

    page = max(
        _int_or(query.get("page"), 1),
        1,
    )

    limit = min(
        max(_int_or(query.get("limit"), 20), 1),
        100,
    )

    search = query.get(
        "search",
        "",
    )

    pattern = "%" + search + "%"

    where = """
        user_id = ?
        AND (
          title LIKE ?
          OR deadline LIKE ?
          OR status LIKE ?
          OR priority LIKE ?
        )
    """

    args = (
        user_id,
        pattern,
        pattern,
        pattern,
        pattern,
    )

    total = conn.execute(
        "SELECT COUNT(*) AS n "
        "FROM assignments WHERE "
        + where,
        args,
    ).fetchone()["n"]

    rows = conn.execute(
        "SELECT * FROM assignments WHERE "
        + where
        + " ORDER BY id DESC LIMIT ? OFFSET ?",
        args + (
            limit,
            (page - 1) * limit,
        ),
    ).fetchall()

    return json_response(
        {
            "items": [
                _to_json(row)
                for row in rows
            ],
            "page": page,
            "limit": limit,
            "total": total,
        }
    )


@router.post("/assignments")
async def create_assignment(
    request: Request,
    user_id: int = Depends(require_auth),
):
    """
    POST /assignments

    {
      courseId,
      title,
      deadline,
      status,
      priority
    }

    -> 201 assignment
    """
    body = await read_json_body(
        request
    )

    if body is None:
        raise validation_error(
            "Body must be a JSON object"
        )

    (
        course_id,
        title,
        deadline,
        status,
        priority,
    ) = _read_fields(
        body,
        user_id,
    )

    cursor = conn.execute(
        """
        INSERT INTO assignments (
          user_id,
          course_id,
          title,
          deadline,
          status,
          priority,
          created_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (
            user_id,
            course_id,
            title,
            deadline,
            status,
            priority,
            now_iso(),
        ),
    )

    row = _find(
        user_id,
        str(cursor.lastrowid),
    )

    return json_response(
        _to_json(row),
        status=201,
    )


@router.get(
    "/assignments/{assignment_id}"
)
async def get_assignment(
    assignment_id: str,
    user_id: int = Depends(require_auth),
):
    """
    GET /assignments/{id}
    -> 200 assignment | 404
    """
    row = _find(
        user_id,
        assignment_id,
    )

    if row is None:
        raise not_found(
            "Assignment not found"
        )

    return json_response(
        _to_json(row)
    )


@router.put(
    "/assignments/{assignment_id}"
)
async def update_assignment(
    assignment_id: str,
    request: Request,
    user_id: int = Depends(require_auth),
):
    """
    PUT /assignments/{id}
    -> 200 updated assignment | 404
    """
    row = _find(
        user_id,
        assignment_id,
    )

    if row is None:
        raise not_found(
            "Assignment not found"
        )

    body = await read_json_body(
        request
    )

    if body is None:
        raise validation_error(
            "Body must be a JSON object"
        )

    (
        course_id,
        title,
        deadline,
        status,
        priority,
    ) = _read_fields(
        body,
        user_id,
    )

    conn.execute(
        """
        UPDATE assignments
        SET
          course_id = ?,
          title = ?,
          deadline = ?,
          status = ?,
          priority = ?
        WHERE id = ?
        """,
        (
            course_id,
            title,
            deadline,
            status,
            priority,
            row["id"],
        ),
    )

    updated = _find(
        user_id,
        str(row["id"]),
    )

    return json_response(
        _to_json(updated)
    )


@router.delete(
    "/assignments/{assignment_id}"
)
async def delete_assignment(
    assignment_id: str,
    user_id: int = Depends(require_auth),
):
    """
    DELETE /assignments/{id}
    -> 204 | 404
    """
    row = _find(
        user_id,
        assignment_id,
    )

    if row is None:
        raise not_found(
            "Assignment not found"
        )

    conn.execute(
        "DELETE FROM assignments WHERE id = ?",
        (row["id"],),
    )

    return Response(
        status_code=204
    )