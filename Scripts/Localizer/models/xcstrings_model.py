from pydantic import BaseModel, RootModel
from typing import Literal, Optional
import json
import sys

sys.path.append("..")

from .strings_response_model import (
    StringsResponse,
    StringsResponseEntry,
)

from utilities.pbx_util import extract_known_regions
import constants as c


class StringUnit(BaseModel):
    state: Literal["translated", "needs_review", "new"]
    value: str


class Localization(BaseModel):
    stringUnit: StringUnit


class Localizations(RootModel):
    root: dict[str, Localization]

    @classmethod
    def from_strings_response_entry(cls, entry: StringsResponseEntry):
        pbxproj_path = c.PBXPROJ_PATH
        if not pbxproj_path:
            return Localizations({})

        language_keys = extract_known_regions(pbxproj_file=pbxproj_path)

        return Localizations(
            {
                key: Localization(
                    stringUnit=StringUnit(
                        state="translated", value=entry.localizations[key] or ""
                    )
                )
                for key in language_keys
            }
        )


class StringEntry(BaseModel):
    localizations: Localizations = Localizations({})


class Strings(RootModel):
    root: dict[str, StringEntry]


class XCStringsFile(BaseModel):
    sourceLanguage: str = "en"
    strings: Strings
    version: str = "1.0"

    @classmethod
    def from_json_file(cls, file_path: str):
        with open(file_path, "r", encoding="utf-8") as file:
            json_data = json.load(file)
            return XCStringsFile(**json_data)

    @classmethod
    def from_strings_response(cls, response: StringsResponse):
        strings = Strings(
            {
                entry.key: StringEntry(
                    localizations=Localizations.from_strings_response_entry(entry=entry)
                )
                for entry in response.root
            }
        )
        return XCStringsFile(strings=strings)

    @property
    def keys(self):
        return self.strings.root.keys()

    @property
    def empty_keys(self):
        pbxproj_file = c.PBXPROJ_PATH
        if not pbxproj_file:
            return [
                key
                for key in self.keys
                if not self.strings.root[key].localizations.root
            ]

        languages = extract_known_regions(pbxproj_file=pbxproj_file)
        
        return [
            key
            for key in self.keys
            if len(self.strings.root[key].localizations.root.keys()) < len(languages)
        ]


class XCStringsFileAggregator:
    @classmethod
    def construct(cls, files: list[XCStringsFile]) -> XCStringsFile:
        strings = Strings({})
        for file in files:
            strings.root = strings.root | file.strings.root
        file = XCStringsFile(strings=strings)
        return file
