"""Tests for InventoryStatus enum."""

from app.schemas.inventory import InventoryStatus


def test_has_in_stock():
    assert InventoryStatus.in_stock == "in_stock"


def test_has_low_stock():
    assert InventoryStatus.low_stock == "low_stock"


def test_has_out_of_stock():
    assert InventoryStatus.out_of_stock == "out_of_stock"


def test_exactly_three_values():
    assert len(InventoryStatus) == 3
