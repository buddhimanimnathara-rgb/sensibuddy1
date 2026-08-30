from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware

import os
import uuid
import shutil
import subprocess

import torch
import librosa

from transformers import (
    Wav2Vec2ForCTC,
    Wav2Vec2Processor,
)



# FASTAPI APP
app = FastAPI(
    title="SensiBuddy Speech Recognition API",
    version="1.0.0",
)



# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# FOLDERS
BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)

UPLOAD_FOLDER = os.path.join(
    BASE_DIR,
    "uploads"
)

TEMP_FOLDER = os.path.join(
    BASE_DIR,
    "temp_audio"
)

os.makedirs(
    UPLOAD_FOLDER,
    exist_ok=True,
)

os.makedirs(
    TEMP_FOLDER,
    exist_ok=True,
)



# MODEL NAMES
SINHALA_MODEL_NAME = (
    "janiduchamika/"
    "wav2vec2-xls-r-300m-sinhala-general-185k"
)

TAMIL_MODEL_NAME = (
    "manandey/"
    "wav2vec2-large-xlsr-tamil"
)



# DEVICE
DEVICE = (
    "cuda"
    if torch.cuda.is_available()
    else "cpu"
)

print("")
print("======================================")
print(f"Using device: {DEVICE}")
print("======================================")



# LOAD SINHALA MODEL
print("")
print("======================================")
print("Loading Sinhala wav2vec2 model...")
print("======================================")

sinhala_processor = Wav2Vec2Processor.from_pretrained(
    SINHALA_MODEL_NAME
)

sinhala_model = Wav2Vec2ForCTC.from_pretrained(
    SINHALA_MODEL_NAME
)

sinhala_model.to(DEVICE)

sinhala_model.eval()

print("Sinhala model loaded successfully!")



# LOAD TAMIL MODEL
print("")
print("======================================")
print("Loading Tamil wav2vec2 model...")
print("======================================")

tamil_processor = Wav2Vec2Processor.from_pretrained(
    TAMIL_MODEL_NAME
)

tamil_model = Wav2Vec2ForCTC.from_pretrained(
    TAMIL_MODEL_NAME
)

tamil_model.to(DEVICE)

tamil_model.eval()

print("Tamil model loaded successfully!")



# HOME
@app.get("/")
def home():

    return {
        "success": True,
        "message": "SensiBuddy Speech API is running!",
        "supported_languages": [
            "si",
            "ta",
        ],
    }



# HEALTH CHECK
@app.get("/health")
def health():

    return {
        "success": True,
        "status": "healthy",
        "device": DEVICE,
    }



# CONVERT AUDIO TO WAV
def convert_audio_to_wav(
    input_path: str,
    output_path: str,
):

    print("")
    print("======================================")
    print(" Converting audio to WAV...")
    print(f"Input: {input_path}")
    print(f"Output: {output_path}")
    print("======================================")

    command = [
        "ffmpeg",
        "-y",
        "-i",
        input_path,
        "-ac",
        "1",
        "-ar",
        "16000",
        "-vn",
        output_path,
    ]

    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    if result.returncode != 0:

        print(" FFmpeg error:")
        print(result.stderr)

        raise Exception(
            "Audio conversion failed. "
            "Make sure FFmpeg is installed and added to PATH."
        )

    if not os.path.exists(
        output_path
    ):
        raise Exception(
            "Converted WAV file was not created."
        )

    print(" Audio converted successfully")



# LOAD AUDIO
def load_audio(
    audio_path: str,
):

    print(
        f" Loading audio: {audio_path}"
    )

    audio, sample_rate = librosa.load(
        audio_path,
        sr=16000,
        mono=True,
    )

    if len(audio) == 0:
        raise Exception(
            "Audio file is empty."
        )

    print(
        f" Sample rate: {sample_rate}"
    )

    print(
        f" Audio samples: {len(audio)}"
    )

    return audio



# SINHALA TRANSCRIPTION
def transcribe_sinhala(
    audio_path: str,
) -> str:

    print("")
    print("======================================")
    print(" Processing Sinhala audio...")
    print("======================================")

    audio = load_audio(
        audio_path
    )

    inputs = sinhala_processor(
        audio,
        sampling_rate=16000,
        return_tensors="pt",
        padding=True,
    )

    input_values = (
        inputs.input_values
        .to(DEVICE)
    )

    with torch.no_grad():

        logits = sinhala_model(
            input_values
        ).logits

    predicted_ids = torch.argmax(
        logits,
        dim=-1,
    )

    text = sinhala_processor.batch_decode(
        predicted_ids
    )[0]

    text = text.strip()

    print(
        f"Sinhala Result: {text}"
    )

    return text


# ============================================================
# TAMIL TRANSCRIPTION
# ============================================================

def transcribe_tamil(
    audio_path: str,
) -> str:

    print("")
    print("======================================")
    print(" Processing Tamil audio...")
    print("======================================")

    audio = load_audio(
        audio_path
    )

    inputs = tamil_processor(
        audio,
        sampling_rate=16000,
        return_tensors="pt",
        padding=True,
    )

    input_values = (
        inputs.input_values
        .to(DEVICE)
    )

    with torch.no_grad():

        logits = tamil_model(
            input_values
        ).logits

    predicted_ids = torch.argmax(
        logits,
        dim=-1,
    )

    text = tamil_processor.batch_decode(
        predicted_ids
    )[0]

    text = text.strip()

    print(
        f"Tamil Result: {text}"
    )

    return text


# ============================================================
# TRANSCRIBE API
# ============================================================

@app.post("/transcribe")
async def transcribe_audio(

    language: str = Form(...),

    file: UploadFile = File(...),

):

    print("")
    print("")
    print("================================================")
    print(" NEW AUDIO RECEIVED")
    print("================================================")

    print(
        f"Language: {language}"
    )

    print(
        f"File name: {file.filename}"
    )

    print(
        f"Content type: {file.content_type}"
    )



    # NORMALIZE LANGUAGE
    language = (
        language
        .lower()
        .strip()
    )

    if language == "sinhala":
        language = "si"

    elif language == "tamil":
        language = "ta"



    # VALIDATE LANGUAGE

    if language not in [
        "si",
        "ta",
    ]:

        return {
            "success": False,
            "error": (
                "Unsupported language. "
                "Use 'si' or 'ta'."
            ),
        }



    # FILE EXTENSION

    original_name = (
        file.filename
        or ""
    )

    file_extension = os.path.splitext(
        original_name
    )[1].lower()


    # Default extension
    if not file_extension:

        if file.content_type == "audio/ogg":
            file_extension = ".ogg"

        elif file.content_type == "audio/wav":
            file_extension = ".wav"

        else:
            file_extension = ".m4a"



    # CREATE UNIQUE FILE NAMES

    file_id = str(
        uuid.uuid4()
    )

    original_file_name = (
        f"{file_id}"
        f"{file_extension}"
    )

    original_file_path = os.path.join(
        UPLOAD_FOLDER,
        original_file_name,
    )

    wav_file_name = (
        f"{file_id}.wav"
    )

    wav_file_path = os.path.join(
        TEMP_FOLDER,
        wav_file_name,
    )


    try:


        # SAVE UPLOADED AUDIO

        with open(
            original_file_path,
            "wb",
        ) as buffer:

            shutil.copyfileobj(
                file.file,
                buffer,
            )

        print(
            f" Audio saved: "
            f"{original_file_path}"
        )



        # CHECK FILE SIZE
        file_size = os.path.getsize(
            original_file_path
        )

        print(
            f" File size: "
            f"{file_size} bytes"
        )

        if file_size == 0:

            raise Exception(
                "Received audio file is empty."
            )



        # CONVERT TO STANDARD WAV

        convert_audio_to_wav(
            original_file_path,
            wav_file_path,
        )



        # SINHALA

        if language == "si":

            text = transcribe_sinhala(
                wav_file_path
            )



        # TAMIL

        elif language == "ta":

            text = transcribe_tamil(
                wav_file_path
            )



        # RESULT

        print("")
        print("======================================")
        print(
            f" FINAL RECOGNIZED TEXT: {text}"
        )
        print("======================================")

        return {
            "success": True,
            "language": language,
            "text": text,
        }


    except Exception as e:

        print("")
        print("======================================")
        print(
            f" TRANSCRIPTION ERROR: {e}"
        )
        print("======================================")

        return {
            "success": False,
            "error": str(e),
        }


    finally:


        # CLOSE UPLOAD FILE

        await file.close()



        # DELETE ORIGINAL AUDIO

        if os.path.exists(
            original_file_path
        ):

            try:

                os.remove(
                    original_file_path
                )

                print(
                    " Original audio deleted"
                )

            except Exception as e:

                print(
                    f" Could not delete "
                    f"original audio: {e}"
                )



        # DELETE CONVERTED WAV

        if os.path.exists(
            wav_file_path
        ):

            try:

                os.remove(
                    wav_file_path
                )

                print(
                    " Temporary WAV deleted"
                )

            except Exception as e:

                print(
                    f" Could not delete "
                    f"temporary WAV: {e}"
                )