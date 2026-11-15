"""Core statistics functions."""


def mean(values):
    """Arithmetic mean of a non-empty sequence of numbers."""
    if not values:
        raise ValueError("mean() needs at least one value, got an empty sequence")
    return sum(values) / len(values)
