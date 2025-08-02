from pydantic import BaseModel, RootModel


class StringsResponseEntryLocalization(BaseModel):
    language_key: str
    value: str


class StringsResponseEntryLocalizations(RootModel):
    root: list[StringsResponseEntryLocalization]

    def __getitem__(self, key):
        return next(
            (item.value for item in self.root if item.language_key == key), None
        )

    def __setitem__(self, key, item):
        existing_item = next((x for x in self.root if x.language_key == key), None)
        if existing_item:
            self.root.remove(existing_item)
        self.root.append(StringsResponseEntryLocalization(language_key=key, value=item))


class StringsResponseEntry(BaseModel):
    key: str
    localizations: StringsResponseEntryLocalizations


class StringsResponse(RootModel):
    root: list[StringsResponseEntry]
