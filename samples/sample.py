#!/usr/bin/env python3
"""Exercise the token classes the Mapping colours for Python.

Decorators, ``self``, builtin functions and types, constants, ``None``,
brackets, strings with escapes and comments all appear below.
"""

from __future__ import annotations

import functools
import os
from dataclasses import dataclass, field
from pathlib import Path

MAX_RETRIES = 3
DEFAULT_NAME = "jobs"


def retry(times: int = MAX_RETRIES):
    """A decorator factory for the decorator lines below."""

    def wrap(fn):
        @functools.wraps(fn)
        def inner(*args, **kwargs):
            last = None
            for attempt in range(times):  # a trailing comment
                try:
                    return fn(*args, **kwargs)
                except ValueError as exc:
                    last = exc
            raise RuntimeError(f"gave up after {times} tries") from last

        return inner

    return wrap


@dataclass
class Queue:
    name: str = DEFAULT_NAME
    limit: int = 8
    items: list[int] = field(default_factory=list)

    @property
    def size(self) -> int:
        return len(self.items)

    @classmethod
    def from_env(cls) -> Queue:
        return cls(name=os.environ.get("QUEUE", DEFAULT_NAME))

    @retry(times=2)
    def push(self, item: int | None) -> bool:
        if item is None or not isinstance(item, int):
            raise ValueError(f"bad item: {item!r}")
        if self.size >= self.limit:
            return False
        self.items.append(item)
        return True


class Pipeline(Queue):
    def describe(self, ratio: float = 0.5, ok: bool = True) -> str:
        label = "idle\n" if self.size == 0 else "busy\t"
        path = Path(r"C:\raw\path") / b"bytes".decode()
        match self.size:
            case 0:
                return label
            case n if n > 0xFF:
                return f"{label}{n:>4}"
            case _:
                return str(path)

    def dump(self) -> None:
        with open(os.devnull, "w", encoding="utf-8") as fh:
            print(*self.items, sep=", ", file=fh)


if __name__ == "__main__":
    q = Pipeline.from_env()
    double = lambda x: x * 2
    print(q.push(1), sorted({2, 3}), double(4), {"k": [1, 2]}, (5,))
