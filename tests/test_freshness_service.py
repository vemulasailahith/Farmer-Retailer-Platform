import unittest
import os
import sys

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.freshness_service import FreshnessDetectionService
import torch
from torchvision import models

class TestFreshnessDetectionService(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.models_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "models"))
        cls.model_path = os.path.join(cls.models_dir, "spoilage_classifier.pth")

        if not os.path.exists(cls.model_path):
            raise FileNotFoundError(
                f"[Test Error] Missing trained model file 'spoilage_classifier.pth' in '{cls.models_dir}'."
            )

        cls.service = FreshnessDetectionService(model_path=cls.model_path)
        cls.test_image_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "test_images", "sample_produce.jpg"))

    def test_1_service_and_model_loaded(self):
        """Verify service initializes, model loads state_dict successfully and is PyTorch MobileNetV2."""
        self.assertIsNotNone(self.service.model)
        self.assertTrue(os.path.exists(self.model_path))
        self.assertIsInstance(self.service.model, models.MobileNetV2)

    def test_2_valid_image_inference(self):
        """Verify image classification returns valid classes, probabilities [0, 1], sum ~ 1, and confidence."""
        if not os.path.exists(self.test_image_path):
            self.skipTest(f"Test image not found at {self.test_image_path}")

        result = self.service.predict(self.test_image_path)

        self.assertIn("predicted_class", result)
        self.assertIn("fresh_probability", result)
        self.assertIn("rotten_probability", result)
        self.assertIn("confidence", result)

        predicted_class = result["predicted_class"]
        fresh_prob = result["fresh_probability"]
        rotten_prob = result["rotten_probability"]
        confidence = result["confidence"]

        # 1. Class must be 'fresh' or 'rotten'
        self.assertIn(predicted_class, ["fresh", "rotten"])

        # 2. Probabilities must be between 0.0 and 1.0
        self.assertGreaterEqual(fresh_prob, 0.0)
        self.assertLessEqual(fresh_prob, 1.0)
        self.assertGreaterEqual(rotten_prob, 0.0)
        self.assertLessEqual(rotten_prob, 1.0)

        # 3. Sum of probabilities should be approximately 1.0
        self.assertAlmostEqual(fresh_prob + rotten_prob, 1.0, delta=0.01)

        # 4. Confidence should be between 0.0 and 1.0
        self.assertGreaterEqual(confidence, 0.0)
        self.assertLessEqual(confidence, 1.0)

        print(f"\n[Inference Output Log] Image: {self.test_image_path}")
        print(f"  Predicted Class: {predicted_class}")
        print(f"  Fresh Prob: {fresh_prob}")
        print(f"  Rotten Prob: {rotten_prob}")
        print(f"  Confidence: {confidence}")

    def test_3_missing_image_raises_file_not_found(self):
        """Verify nonexistent image path raises FileNotFoundError."""
        non_existent_img = os.path.join(os.path.dirname(self.test_image_path), "non_existent_img_123.jpg")
        with self.assertRaises(FileNotFoundError):
            self.service.predict(non_existent_img)

    def test_4_invalid_model_path_raises_file_not_found(self):
        """Verify non-existent model path raises FileNotFoundError."""
        invalid_model = os.path.join(self.models_dir, "non_existent_model_file.pth")
        with self.assertRaises(FileNotFoundError):
            FreshnessDetectionService(model_path=invalid_model)

    def test_5_invalid_image_file_raises_error(self):
        """Verify corrupted/invalid image file raises ValueError."""
        corrupt_path = os.path.join(os.path.dirname(self.test_image_path), "corrupt.jpg")
        with open(corrupt_path, "w") as f:
            f.write("NOT_AN_IMAGE_DATA")

        try:
            with self.assertRaises(ValueError):
                self.service.predict(corrupt_path)
        finally:
            if os.path.exists(corrupt_path):
                os.remove(corrupt_path)

if __name__ == "__main__":
    unittest.main()
