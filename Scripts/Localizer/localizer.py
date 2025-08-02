import sys

from google import genai
from google.genai import types

import constants as c

from models import (
    XCStringsFile,
    XCStringsFileAggregator,
    StringsResponse,
)

from utilities.pbx_util import extract_known_regions


def main():
    xcstrings_path = c.XCSTRINGS_PATH or (sys.argv[1] if len(sys.argv) > 1 else None)
    gemini_model = c.GEMINI_MODEL or "gemini-2.5-flash"

    if xcstrings_path is None:
        print(
            "Provide a path to an .xcstrings file using the XCSTRINGS_PATH environment variable or command-line arguments."
        )
        return

    xcstrings = XCStringsFile.from_json_file(file_path=xcstrings_path)
    localizable_keys = xcstrings.empty_keys

    pbxproj_path = c.PBXPROJ_PATH

    if not pbxproj_path:
        print(
            "Provide a path to the .pbxproj file within the .xcodeproj file using the PBXPROJ_PATH environment variable."
        )
        return

    language_keys = extract_known_regions(pbxproj_file=pbxproj_path)

    if not localizable_keys:
        print("No keys left to localize.")
        return

    client = genai.Client()

    response = client.models.generate_content(
        model=gemini_model,
        contents=f"Localization keys: {', '.join(localizable_keys)}\nLanguage keys: {', '.join(language_keys)}",
        config=types.GenerateContentConfig(
            system_instruction="You are a localization expert. Translate the provided localization keys into each language specified by the corresponding key.",
            thinking_config=types.ThinkingConfig(thinking_budget=0),
            response_mime_type="application/json",
            response_schema=StringsResponse,
        ),
    )

    result: StringsResponse = response.parsed  # pyright: ignore[reportAssignmentType]
    result_xcstrings = XCStringsFile.from_strings_response(response=result)

    aggregated_xcstrings = XCStringsFileAggregator.construct(
        files=[xcstrings, result_xcstrings]
    )

    with open(xcstrings_path, "w", encoding="utf-8") as file:
        file.write(aggregated_xcstrings.model_dump_json(indent=2))


if __name__ == "__main__":
    main()
