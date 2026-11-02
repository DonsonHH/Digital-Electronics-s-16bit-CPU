"""Keep historical r1/r2 generators from replacing the architecture-source edition."""
from pathlib import Path
import zipfile
from xml.etree import ElementTree

def ensure_legacy_output(path):
    path=Path(path)
    if not path.exists():return
    try:
        with zipfile.ZipFile(path)as z:root=ElementTree.fromstring(z.read('docProps/core.xml'))
        version=root.findtext('{http://schemas.openxmlformats.org/package/2006/metadata/core-properties}version','')
    except (zipfile.BadZipFile,KeyError,ElementTree.ParseError)as exc:
        raise ValueError('Refusing to overwrite an existing unrecognized document: '+str(path))from exc
    if version.startswith('AC1-architecture-'):
        raise ValueError('Architecture document must use 文档源/build_core_document.py; legacy generators require --output to a different archive path')
