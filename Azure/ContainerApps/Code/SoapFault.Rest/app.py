from fastapi import FastAPI,HTTPException,Response
import re

app = FastAPI()

@app.get("/version")
def get_version():
    return { "version" : "1.11g" }

@app.get("/test/{text}")
def test_text(text: str):
    if (text == 'error'):
        raise HTTPException(status_code=500, detail="Do not write 'error'")
    # XML error responses
    match = re.fullmatch(r"xmlerror(\d{3})", text)
    if match:
        status_code = int(match.group(1))

        if status_code >= 400:
            xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<error>
    <status>{status_code}</status>
    <message>Simulated XML error response</message>
    <details>{'This is a very long XML error message. ' * 40}</details>
</error>"""

            return Response(
                content=xml,
                status_code=status_code,
                media_type="application/xml"
            )

    # JSON error responses
    match = re.fullmatch(r"error(\d{3})", text)
    if match:
        status_code = int(match.group(1))

        if status_code >= 400:
            message = (
                f"HTTP {status_code} simulated error. "
                f"Input text was '{text}'. "
                + ("This is a deliberately long error message for testing error handling. " * 40)
            )

            raise HTTPException(
                status_code=status_code,
                detail=message
            )
    return { "response" : f'text is {text}' }

##@app.get("/health")
## def health():
##     return {"ok": True}
