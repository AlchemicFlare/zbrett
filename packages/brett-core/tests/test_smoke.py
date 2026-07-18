# SPDX-FileCopyrightText: 2026 protagx <hello@protagx.com>
# SPDX-License-Identifier: EUPL-1.2
from importlib import import_module


def test_import():
    assert import_module("brett.core") is not None
