
import httpx
from typing import Any


class APIError(Exception):
    def __init__(self, message: str, status_code: int | None = None):
        self.message = message
        self.status_code = status_code
        super().__init__(message)


class APIClient:
    def __init__(self, base_url: str = "http://127.0.0.1:8000"):
        self.base_url = base_url.rstrip("/")
        self.timeout = 15.0

    async def _request(
        self,
        method: str,
        endpoint: str,
        data: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        try:
            async with httpx.AsyncClient(
                base_url=self.base_url,
                timeout=self.timeout,
            ) as client:
                response = await client.request(
                    method,
                    endpoint,
                    json=data,
                )

            try:
                result = response.json()
            except ValueError:
                result = {}

            if response.is_error:
                if isinstance(result, dict):
                    detail = result.get("detail", "API request failed.")
                else:
                    detail = "API request failed."

                raise APIError(str(detail), response.status_code)

            if not isinstance(result, dict):
                raise APIError("Unexpected API response.")

            return result

        except httpx.TimeoutException:
            raise APIError("The server took too long to respond.")

        except httpx.RequestError:
            raise APIError(
                "Cannot connect to Boogle. Check that the server is running."
            )

    # ---------------- SIGNUP ----------------

    async def signup(
        self,
        full_name: str,
        email: str,
        password: str,
    ) -> dict[str, Any]:
        return await self._request(
            "POST",
            "/auth/signup",
            {
                "full_name": full_name,
                "email": email,
                "password": password,
            },
        )

    async def verify_signup_otp(
        self,
        email: str,
        otp: str,
    ) -> dict[str, Any]:
        return await self._request(
            "POST",
            "/auth/verify-signup-otp",
            {
                "email": email,
                "otp": otp,
            },
        )

    async def resend_signup_otp(
        self,
        email: str,
    ) -> dict[str, Any]:
        return await self._request(
            "POST",
            "/auth/resend-signup-otp",
            {"email": email},
        )

    # ---------------- LOGIN ----------------

    async def login(
        self,
        email: str,
        password: str,
        remember_me: bool = False,
    ) -> dict[str, Any]:
        return await self._request(
            "POST",
            "/auth/login",
            {
                "email": email,
                "password": password,
                "remember_me": remember_me,
            },
        )

    async def verify_login_otp(
        self,
        email: str,
        otp: str,
        remember_me: bool = False,
    ) -> dict[str, Any]:
        return await self._request(
            "POST",
            "/auth/verify-login-otp",
            {
                "email": email,
                "otp": otp,
                "remember_me": remember_me,
            },
        )

    async def resend_login_otp(
        self,
        email: str,
    ) -> dict[str, Any]:
        return await self._request(
            "POST",
            "/auth/resend-login-otp",
            {"email": email},
        )
