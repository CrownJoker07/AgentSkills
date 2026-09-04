import sys


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: extract_pdf.py <pdf-path>")

    from pypdf import PdfReader

    reader = PdfReader(sys.argv[1])
    for page_number, page in enumerate(reader.pages, start=1):
        print(f"--- page {page_number} ---")
        print(page.extract_text() or "")


if __name__ == "__main__":
    main()
