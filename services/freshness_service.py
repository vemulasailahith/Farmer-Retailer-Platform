import os
import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image

class FreshnessDetectionService:
    """
    Module 4: Freshness / Quality Detection Service
    Performs image classification using a fine-tuned MobileNetV2 architecture
    to classify crop/vegetable/fruit produce images into 'fresh' or 'rotten'.
    """

    CLASS_MAPPING = {
        0: "fresh",
        1: "rotten"
    }

    def __init__(self, model_path: str = None):
        if model_path is None:
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            model_path = os.path.join(base_dir, "models", "spoilage_classifier.pth")

        self.model_path = model_path
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        if not os.path.exists(self.model_path):
            raise FileNotFoundError(
                f"[FreshnessDetectionService] PyTorch model file not found at: '{self.model_path}'"
            )

        # Image preprocessing pipeline matching training specifications
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225]
            )
        ])

        self._load_model()

    def _load_model(self):
        """Reconstructs MobileNetV2 architecture and loads saved state_dict."""
        try:
            # Reconstruct MobileNetV2 base architecture
            model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)

            # Freeze feature extraction layers
            for param in model.features.parameters():
                param.requires_grad = False

            # Replace classifier head for 2 classes (fresh vs rotten)
            model.classifier[1] = nn.Linear(model.last_channel, 2)

            # Load trained state dictionary
            state_dict = torch.load(self.model_path, map_location=self.device)
            model.load_state_dict(state_dict)

            model.to(self.device)
            model.eval()
            self.model = model
        except Exception as e:
            raise RuntimeError(f"[FreshnessDetectionService] Failed to load PyTorch model from '{self.model_path}': {str(e)}")

    def predict(self, image_path: str) -> dict:
        """
        Classifies an input produce image into 'fresh' or 'rotten'.
        Returns probabilities and confidence score.
        """
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"[FreshnessDetectionService] Input image file not found: '{image_path}'")

        # Open image with PIL and convert to RGB
        try:
            img = Image.open(image_path).convert("RGB")
        except Exception as e:
            raise ValueError(f"[FreshnessDetectionService] Could not open or process image file '{image_path}': {str(e)}")

        # Preprocess image
        input_tensor = self.transform(img).unsqueeze(0).to(self.device)

        # Perform inference
        with torch.no_grad():
            logits = self.model(input_tensor)
            probabilities = torch.softmax(logits, dim=1)[0]

        fresh_prob = float(probabilities[0].item())
        rotten_prob = float(probabilities[1].item())

        predicted_class_idx = 0 if fresh_prob >= rotten_prob else 1
        predicted_class = self.CLASS_MAPPING[predicted_class_idx]
        confidence = fresh_prob if predicted_class_idx == 0 else rotten_prob

        return {
            "predicted_class": predicted_class,
            "fresh_probability": round(fresh_prob, 4),
            "rotten_probability": round(rotten_prob, 4),
            "confidence": round(confidence, 4)
        }
