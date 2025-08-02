import os
from dotenv import load_dotenv

load_dotenv()

XCSTRINGS_PATH = os.getenv("XCSTRINGS_PATH")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL")
PBXPROJ_PATH = os.getenv("PBXPROJ_PATH")
