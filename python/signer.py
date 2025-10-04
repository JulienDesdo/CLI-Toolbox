#!/usr/bin/env python3
"""
signer.py — outil local pour extraire et remplacer des pages PDF à signer.
Utilisation :
  - Extraire une page à signer :
      python signer.py --input contrat.pdf --page 5 --extract-only

  - Remplacer la page par la version signée :
      python signer.py --input contrat.pdf --page 5 --signed page_signee.pdf --output contrat_signe.pdf
"""

import argparse
from PyPDF2 import PdfReader, PdfWriter
from pathlib import Path
import sys


def extract_page(input_path: Path, page_number: int, output_path: Path):
    """Extrait une page spécifique d’un PDF."""
    reader = PdfReader(str(input_path))
    writer = PdfWriter()

    if page_number < 1 or page_number > len(reader.pages):
        sys.exit(f"Numéro de page invalide (le document contient {len(reader.pages)} pages).")

    page = reader.pages[page_number - 1]
    writer.add_page(page)

    with open(output_path, "wb") as f:
        writer.write(f)

    print(f"Page {page_number} extraite dans : {output_path}")


def replace_page(input_path: Path, page_number: int, signed_page_path: Path, output_path: Path):
    """Remplace une page dans un PDF par une autre PDF (une seule page)."""
    reader = PdfReader(str(input_path))
    signed_reader = PdfReader(str(signed_page_path))
    writer = PdfWriter()

    if page_number < 1 or page_number > len(reader.pages):
        sys.exit(f"Numéro de page invalide (le document contient {len(reader.pages)} pages).")

    if len(signed_reader.pages) != 1:
        sys.exit("Le fichier signé doit contenir exactement UNE page.")

    # Ajouter toutes les pages sauf celle à remplacer
    for i, page in enumerate(reader.pages, start=1):
        if i == page_number:
            writer.add_page(signed_reader.pages[0])
        else:
            writer.add_page(page)

    with open(output_path, "wb") as f:
        writer.write(f)

    print(f"Page {page_number} remplacée et PDF final enregistré dans : {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Extraire ou remplacer des pages dans un PDF pour signature.")
    parser.add_argument("--input", required=True, help="PDF original à traiter.")
    parser.add_argument("--page", required=True, type=int, help="Numéro de la page à extraire ou remplacer (1-indexé).")
    parser.add_argument("--signed", help="PDF contenant la page signée (une seule page).")
    parser.add_argument("--output", help="Nom du PDF de sortie (défaut : *_signed.pdf).")
    parser.add_argument("--extract-only", action="store_true", help="N’extraire que la page à signer.")

    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        sys.exit(f"Le fichier d’entrée n’existe pas : {input_path}")

    if args.extract_only:
        output_path = Path(args.output) if args.output else input_path.with_name(f"{input_path.stem}_page_{args.page}.pdf")
        extract_page(input_path, args.page, output_path)
        return

    if not args.signed:
        sys.exit("Vous devez fournir --signed si vous ne faites pas --extract-only.")

    signed_path = Path(args.signed)
    if not signed_path.exists():
        sys.exit(f"Le fichier signé n’existe pas : {signed_path}")

    output_path = Path(args.output) if args.output else input_path.with_name(f"{input_path.stem}_signed.pdf")

    replace_page(input_path, args.page, signed_path, output_path)


if __name__ == "__main__":
    main()
