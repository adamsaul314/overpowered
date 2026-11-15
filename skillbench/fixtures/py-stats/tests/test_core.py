import unittest

from stats.core import mean


class MeanTest(unittest.TestCase):
    def test_mean_of_three_values(self):
        self.assertEqual(mean([1, 2, 6]), 3)

    def test_mean_of_empty_list_raises(self):
        with self.assertRaises(ValueError):
            mean([])


if __name__ == "__main__":
    unittest.main()
