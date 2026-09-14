import os
import sys
import tempfile

MIN_PAGE_CHARS = 40
MIN_DISTINCT_CHARS = 60


def page_readable(text):
    content = "".join({line.strip() for line in text.splitlines() if line.strip()})
    distinct = {c for c in content if c.isalnum()}
    return len(content) >= MIN_PAGE_CHARS and len(distinct) >= MIN_DISTINCT_CHARS


def text_pages(path):
    from pypdf import PdfReader

    reader = PdfReader(path)
    return [(n, reader.pages[n - 1].extract_text() or "") for n in range(1, len(reader.pages) + 1)]


def ocr_pages(path, numbers):
    try:
        import pymupdf as fitz
    except ImportError:
        import fitz
    from ocrmac import ocrmac

    doc = fitz.open(path)
    results = {}
    with tempfile.TemporaryDirectory() as tmp_dir:
        for number in numbers:
            image = os.path.join(tmp_dir, f"page-{number}.png")
            doc.load_page(number - 1).get_pixmap(matrix=fitz.Matrix(3, 3)).save(image)
            entries = [entry for entry in ocrmac.OCR(
                image, language_preference=["zh-Hans", "en-US"]
            ).recognize() if entry[0].strip()]
            entries.sort(key=lambda entry: (-entry[2][1], entry[2][0]))
            text = "\n".join(entry[0].strip() for entry in entries)
            confidence = sum(entry[1] for entry in entries) / len(entries) if entries else 0.0
            results[number] = (text, confidence)
    return results


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: extract_pdf.py <pdf-path>")

    path = sys.argv[1]
    pages = dict(text_pages(path))
    weak = [number for number, text in pages.items() if not page_readable(text)]
    results = {}

    if weak:
        if sys.platform != "darwin":
            raise SystemExit(
                f"pages {weak} have no extractable text and OCR requires macOS Vision; "
                "ask for a text version of the resume"
            )
        try:
            results = ocr_pages(path, weak)
        except ImportError as error:
            raise SystemExit(
                f"image-only pages detected ({weak}); install pymupdf and ocrmac into ./.venv "
                f"with user approval, then rerun: {error}"
            )
        pages.update({number: text for number, (text, _) in results.items()})

    for number in sorted(pages):
        if number in results:
            text = pages[number]
            if text.strip():
                print(f"--- page {number} (ocr, confidence {results[number][1]:.2f}) ---")
            else:
                print(f"--- page {number} (ocr, no content) ---")
        else:
            print(f"--- page {number} ---")
        print(pages[number])

    if not any(page_readable(text) for text in pages.values()):
        print("WARNING: no readable content after text extraction and OCR", file=sys.stderr)


if __name__ == "__main__":
    main()
