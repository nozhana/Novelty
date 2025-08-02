import re


def extract_known_regions(pbxproj_file: str) -> list[str]:
    with open(pbxproj_file, "r", encoding="utf-8") as file:
        pbxproj_text = file.read()
        match = re.search(r"knownRegions\s*=\s*\((.*?)\);", pbxproj_text, re.DOTALL)
        if not match:
            return []
        region_block = match.group(1)

        regions = re.findall(r"\b([A-Za-z_-]+)\b", region_block)
        return [r for r in regions if r not in ["en", "Base"]]
