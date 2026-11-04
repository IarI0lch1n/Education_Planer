# PAM backend template - Python/FastAPI port.
#
# Start:
#   pip install -r requirements.txt
#   python -m app.main
#
# Env:
#   PORT (default 8080)
#   JWT_SECRET (default dev-secret-change-me)

import os

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import (
    HTTPException as StarletteHTTPException,
)

from . import (
    assignments,
    auth,
    courses,
    files,
    notes,
)
from .errors import ApiError, json_response


app = FastAPI(
    title="PAM Backend Template",
    docs_url=None,
    redoc_url=None,
)


@app.get("/health")
async def health():
    return json_response(
        {
            "status": "ok",
        }
    )


# --------------------------------------------------
# Routers
# --------------------------------------------------

# Original professor template routes.
app.include_router(auth.router)
app.include_router(notes.router)
app.include_router(files.router)

# EduPlan routes.
app.include_router(courses.router)
app.include_router(assignments.router)


# Permissive CORS for laboratory usage.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=[
        "GET",
        "POST",
        "PUT",
        "DELETE",
        "OPTIONS",
    ],
    allow_headers=[
        "Origin",
        "Content-Type",
        "Authorization",
    ],
)


# --------------------------------------------------
# Error handling
# --------------------------------------------------


@app.exception_handler(ApiError)
async def api_error_handler(
    request: Request,
    exc: ApiError,
):
    """
    ApiError is converted to the standard contract:

    {
      "error": {
        "code": "...",
        "message": "..."
      }
    }
    """
    return exc.to_response()


@app.exception_handler(
    StarletteHTTPException
)
async def http_exception_handler(
    request: Request,
    exc: StarletteHTTPException,
):
    """
    FastAPI errors are also converted
    to the same standard error envelope.
    """
    code = {
        401: "UNAUTHORIZED",
        404: "NOT_FOUND",
        409: "EMAIL_TAKEN",
    }.get(
        exc.status_code,
        "VALIDATION_ERROR",
    )

    message = (
        "Route not found"
        if exc.status_code == 404
        else str(exc.detail)
    )

    return json_response(
        {
            "error": {
                "code": code,
                "message": message,
            }
        },
        status=exc.status_code,
    )


@app.exception_handler(
    RequestValidationError
)
async def request_validation_handler(
    request: Request,
    exc: RequestValidationError,
):
    """
    Typed parameter failures return 400
    instead of FastAPI's default 422.
    """
    return json_response(
        {
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Invalid request",
            }
        },
        status=400,
    )


# --------------------------------------------------
# Start
# --------------------------------------------------

if __name__ == "__main__":
    import uvicorn

    port = int(
        os.environ.get(
            "PORT",
            "8080",
        )
    )

    print(
        "Backend listening on "
        f"http://localhost:{port}"
    )

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
    )