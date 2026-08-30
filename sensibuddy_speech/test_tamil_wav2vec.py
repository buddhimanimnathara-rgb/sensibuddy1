import torch
import librosa

from transformers import (
    Wav2Vec2ForCTC,
    Wav2Vec2Processor,
)

MODEL_NAME = (
    "manandey/"
    "wav2vec2-large-xlsr-tamil"
)

AUDIO_FILE = "test_tamil.ogg"


print("Loading Tamil wav2vec2 model...")


# Load processor
processor = Wav2Vec2Processor.from_pretrained(
    MODEL_NAME
)


# Load model
model = Wav2Vec2ForCTC.from_pretrained(
    MODEL_NAME
)


print("Model loaded successfully!")

print("Loading audio...")


# Load and automatically convert to:
# 16 kHz + mono
audio, sample_rate = librosa.load(
    AUDIO_FILE,
    sr=16000,
    mono=True,
)


print(f"Audio sample rate: {sample_rate}")

print("Processing audio...")


# Convert audio to model input
inputs = processor(
    audio,
    sampling_rate=16000,
    return_tensors="pt",
    padding=True,
)


# Run prediction
with torch.no_grad():
    logits = model(
        inputs.input_values
    ).logits


# Get predicted token IDs
predicted_ids = torch.argmax(
    logits,
    dim=-1,
)


# Convert prediction to Tamil text
transcription = processor.batch_decode(
    predicted_ids
)[0]


print("")
print("================================")
print("TAMIL TRANSCRIPTION:")
print(transcription)
print("================================")