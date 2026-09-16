from __future__ import annotations

from a2a.server.agent_execution import RequestContext
from a2a.server.context import ServerCallContext
from a2a.types import Message, MessageSendParams, Part, Role, TextPart

from distributed_a2a.executors import (_incoming_authorization_header,
                                       _mcp_connection_headers)


def _ctx(call_context: ServerCallContext | None) -> RequestContext:
    msg = Message(
        message_id="m-1",
        context_id="ctx-1",
        task_id="task-1",
        role=Role.user,
        parts=[Part(root=TextPart(text="hello"))],
    )
    return RequestContext(
        request=MessageSendParams(message=msg),
        task_id="task-1",
        context_id="ctx-1",
        call_context=call_context,
    )


def test_incoming_authorization_header_reads_lowercase_header() -> None:
    call_context = ServerCallContext(state={"headers": {"authorization": "Bearer abc"}})

    assert _incoming_authorization_header(_ctx(call_context)) == "Bearer abc"


def test_incoming_authorization_header_missing_header() -> None:
    call_context = ServerCallContext(state={"headers": {"x-api-key": "secret"}})

    assert _incoming_authorization_header(_ctx(call_context)) is None


def test_incoming_authorization_header_no_call_context() -> None:
    assert _incoming_authorization_header(_ctx(None)) is None


def test_mcp_connection_headers_merges_forwarded_authorization() -> None:
    headers = _mcp_connection_headers({"x-api-key": "secret"}, "Bearer abc")

    assert headers == {"x-api-key": "secret", "Authorization": "Bearer abc"}


def test_mcp_connection_headers_keeps_static_headers_when_nothing_forwarded() -> None:
    headers = _mcp_connection_headers({"x-api-key": "secret"}, None)

    assert headers == {"x-api-key": "secret"}
