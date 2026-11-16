import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit, parse_qs
from xml.etree import ElementTree as ET
from xml.sax.saxutils import escape

SOAP = "http://schemas.xmlsoap.org/soap/envelope/"


def envelope(body):
    return (
        '<?xml version="1.0" encoding="utf-8"?>'
        f'<soap:Envelope xmlns:soap="{SOAP}" xmlns:m="urn:soap-stub">'
        f"<soap:Body>{body}</soap:Body>"
        "</soap:Envelope>"
    ).encode("utf-8")


def fault(code, message, kind="Server"):
    return envelope(
        "<soap:Fault>"
        f"<faultcode>soap:{kind}</faultcode>"
        f"<faultstring>{escape(message)}</faultstring>"
        "<detail><m:error>"
        f"<m:code>{escape(str(code))}</m:code>"
        f"<m:message>{escape(message)}</m:message>"
        "</m:error></detail>"
        "</soap:Fault>"
    )


class Handler(BaseHTTPRequestHandler):
    def reply(self, status, body, content_type="text/xml; charset=utf-8"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if urlsplit(self.path).path == "/health":
            self.reply(200, b"OK", "text/plain; charset=utf-8")
        else:
            self.reply(404, b"Not found", "text/plain; charset=utf-8")

    def do_POST(self):
        url = urlsplit(self.path)

        if url.path != "/soap":
            self.reply(404, b"Not found", "text/plain; charset=utf-8")
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))

            if not 0 < length <= 1024 * 1024:
                raise ValueError("Expected a SOAP request of at most 1 MiB.")

            raw = self.rfile.read(length)

            if b"<!DOCTYPE" in raw.upper() or b"<!ENTITY" in raw.upper():
                raise ValueError("DTD and entity declarations are not supported.")

            root = ET.fromstring(raw)

            if root.tag != f"{{{SOAP}}}Envelope":
                self.reply(
                    500,
                    fault("VERSION", "Expected SOAP 1.1.", "VersionMismatch"),
                )
                return

            body = root.find(f"{{{SOAP}}}Body")

            if body is None or len(body) != 1:
                raise ValueError("Expected one operation inside SOAP Body.")

        except (ValueError, ET.ParseError) as exc:
            self.reply(500, fault("BAD_REQUEST", str(exc), "Client"))
            return

        # Any operation name is accepted. The query string controls the result.
        mode = parse_qs(url.query).get("mode", ["success"])[0]

        if mode == "success":
            self.reply(
                200,
                envelope(
                    "<m:StubResponse>"
                    "<m:message>Success</m:message>"
                    "</m:StubResponse>"
                ),
            )

        elif mode == "notfound":
            self.reply(
                500,
                fault(404, "The requested customer was not found.", "Client"),
            )

        elif mode == "fail":
            self.reply(500, fault(500, "Simulated server failure."))

        elif mode == "http404":
            # Intentionally return HTTP 404 with a SOAP Fault for testing.
            self.reply(
                404,
                fault(404, "Simulated SOAP fault with HTTP 404.", "Client"),
            )

        else:
            self.reply(
                500,
                fault(
                    "BAD_MODE",
                    "Use success, fail, notfound, or http404.",
                    "Client",
                ),
            )


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8080"))
    print(f"SOAP stub listening on 0.0.0.0:{port}/soap", flush=True)
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()