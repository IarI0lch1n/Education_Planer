# EduPlan courses CRUD.
#
# This module follows the same structure as the professor's notes.py:
# - JWT authentication
# - CRUD
# - pagination
# - server-side search
# - standard API errors
# - data scoped to the current user

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
        "name": row["name"],
        "teacher": row["teacher"],
        "room": row["room"],
        "weekday": row["weekday"],
        "startTime": row["start_time"],
    }


def _find(user_id: int, id_param: str):
    """
    Find a course only among the current user's courses.

    A course belonging to another user is returned as 404,
    exactly like a missing course.
    """
    try:
        course_id = int(id_param)
    except (TypeError, ValueError):
        return None

    return conn.execute(
        "SELECT * FROM courses WHERE id = ? AND user_id = ?",
        (course_id, user_id),
    ).fetchone()


def _int_or(value: Optional[str], default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _read_fields(body):
    name = string_field(body, "name")
    teacher = string_field(body, "teacher")
    room = string_field(body, "room")
    weekday = string_field(body, "weekday")
    start_time = string_field(body, "startTime")

    if name is None:
        raise validation_error("name is required")

    if teacher is None:
        raise validation_error("teacher is required")

    if room is None:
        raise validation_error("room is required")

    if weekday is None:
        raise validation_error("weekday is required")

    if start_time is None:
        raise validation_error("startTime is required")

    return name, teacher, room, weekday, start_time


@router.get("/courses")
async def list_courses(
    request: Request,
    user_id: int = Depends(require_auth),
):
    """
    GET /courses?page=1&limit=20&search=
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

    search = query.get("search", "")

    pattern = "%" + search + "%"

    where = """
        user_id = ?
        AND (
          name LIKE ?
          OR teacher LIKE ?
          OR room LIKE ?
          OR weekday LIKE ?
          OR start_time LIKE ?
        )
    """

    args = (
        user_id,
        pattern,
        pattern,
        pattern,
        pattern,
        pattern,
    )

    total = conn.execute(
        "SELECT COUNT(*) AS n FROM courses WHERE " + where,
        args,
    ).fetchone()["n"]

    rows = conn.execute(
        "SELECT * FROM courses WHERE "
        + where
        + " ORDER BY id DESC LIMIT ? OFFSET ?",
        args + (limit, (page - 1) * limit),
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


@router.post("/courses")
async def create_course(
    request: Request,
    user_id: int = Depends(require_auth),
):
    """
    POST /courses

    {
      name,
      teacher,
      room,
      weekday,
      startTime
    }

    -> 201 course
    """
    body = await read_json_body(request)

    if body is None:
        raise validation_error(
            "Body must be a JSON object"
        )

    (
        name,
        teacher,
        room,
        weekday,
        start_time,
    ) = _read_fields(body)

    cursor = conn.execute(
        """
        INSERT INTO courses (
          user_id,
          name,
          teacher,
          room,
          weekday,
          start_time,
          created_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (
            user_id,
            name,
            teacher,
            room,
            weekday,
            start_time,
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


@router.get("/courses/{course_id}")
async def get_course(
    course_id: str,
    user_id: int = Depends(require_auth),
):
    """
    GET /courses/{id}
    -> 200 course | 404
    """
    row = _find(
        user_id,
        course_id,
    )

    if row is None:
        raise not_found(
            "Course not found"
        )

    return json_response(
        _to_json(row)
    )


@router.put("/courses/{course_id}")
async def update_course(
    course_id: str,
    request: Request,
    user_id: int = Depends(require_auth),
):
    """
    PUT /courses/{id}
    -> 200 updated course | 404
    """
    row = _find(
        user_id,
        course_id,
    )

    if row is None:
        raise not_found(
            "Course not found"
        )

    body = await read_json_body(request)

    if body is None:
        raise validation_error(
            "Body must be a JSON object"
        )

    (
        name,
        teacher,
        room,
        weekday,
        start_time,
    ) = _read_fields(body)

    conn.execute(
        """
        UPDATE courses
        SET
          name = ?,
          teacher = ?,
          room = ?,
          weekday = ?,
          start_time = ?
        WHERE id = ?
        """,
        (
            name,
            teacher,
            room,
            weekday,
            start_time,
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


@router.delete("/courses/{course_id}")
async def delete_course(
    course_id: str,
    user_id: int = Depends(require_auth),
):
    """
    DELETE /courses/{id}
    -> 204 | 404
    """
    row = _find(
        user_id,
        course_id,
    )

    if row is None:
        raise not_found(
            "Course not found"
        )

    conn.execute(
        "DELETE FROM courses WHERE id = ?",
        (row["id"],),
    )

    return Response(
        status_code=204
    )