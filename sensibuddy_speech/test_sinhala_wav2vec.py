import torch
import librosa

from transformers import (
    Wav2Vec2ForCTC,
    Wav2Vec2Processor,
)

MODEL_NAME = (
    "janiduchamika/"
    "wav2vec2-xls-r-300m-sinhala-general-185k"
)

# Test audio file
AUDIO_FILE = "test.ogg"

print("Loading Sinhala wav2vec2 model...")

processor = Wav2Vec2Processor.from_pretrained(
    MODEL_NAME
)

model = Wav2Vec2ForCTC.from_pretrained(
    MODEL_NAME
)

print("Model loaded successfully!")

print("Loading audio...")

audio, sample_rate = librosa.load(
    AUDIO_FILE,
    sr=16000,
    mono=True,
)

print(f"Audio sample rate: {sample_rate}")

print("Processing audio...")

inputs = processor(
    audio,
    sampling_rate=16000,
    return_tensors="pt",
    padding=True,
)

with torch.no_grad():
    logits = model(
        inputs.input_values
    ).logits

predicted_ids = torch.argmax(
    logits,
    dim=-1,
)

transcription = processor.batch_decode(
    predicted_ids
)[0]

print("")
print("================================")
print("SINHALA TRANSCRIPTION:")
print(transcription)
print("================================")