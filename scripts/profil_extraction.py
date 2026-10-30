"""Profilage rapide de l'extraction brute d'annonces (data_job_offer.csv).

Reproduit hors Power BI les contrôles de la couche « Qualité » du modèle :
lignes brutes, annonces uniques (clé = lien), couverture des descriptions,
identifiant d'offre et employeur lus dans l'URL.

Usage :
    python scripts/profil_extraction.py chemin/vers/data_job_offer.csv

Le fichier attendu a trois colonnes : titre, lien, description (UTF-8, avec ou sans BOM).
"""
from __future__ import annotations

import csv
import re
import sys
from collections import defaultdict
from pathlib import Path

# Caractères parasites : espace insécable et espace de largeur nulle.
DIRTY = str.maketrans({0x00A0: " ", 0x200B: None})  # U+00A0 espace insécable, U+200B espace de largeur nulle
URL_RE = re.compile(r"emplois-stage-recrutement/(?P<id>\d+)(?:/(?P<slug>[^/?#]+))?")


def clean(text: str | None) -> str:
    return (text or "").translate(DIRTY).strip()


def employer_slug(slug: str) -> str:
    """Texte après le dernier « -at- » du slug, sinon « unknown » (règle de int_Offres)."""
    return slug.rsplit("-at-", 1)[1] if "-at-" in slug else "unknown"


def main(path: Path) -> None:
    with path.open(encoding="utf-8-sig", newline="") as fh:
        rows = list(csv.DictReader(fh))

    by_link: dict[str, list[dict]] = defaultdict(list)
    for row in rows:
        link = clean(row.get("lien"))
        if link:
            by_link[link].append(row)

    unique = len(by_link)
    # Règle de déduplication du modèle : on garde la ligne à la description la plus longue.
    best = {link: max(group, key=lambda r: len(clean(r.get("description")))) for link, group in by_link.items()}
    described = sum(1 for r in best.values() if clean(r.get("description")))
    with_employer = 0
    ids: set[str] = set()
    for link in best:
        m = URL_RE.search(link)
        if m:
            ids.add(m["id"])
            if m["slug"] and employer_slug(m["slug"]) != "unknown":
                with_employer += 1

    def pct(n: int) -> str:
        return f"{n / unique:.0%}" if unique else "n/a"

    print(f"Lignes brutes            : {len(rows)}")
    print(f"Annonces uniques (lien)  : {unique}  (doublons : {len(rows) - unique}, {1 - unique / len(rows):.0%})")
    print(f"Identifiants d'offre     : {len(ids)}")
    print(f"Avec description         : {described}  ({pct(described)})")
    print(f"Employeur lu dans l'URL  : {with_employer}  ({pct(with_employer)})")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(Path(sys.argv[1]))
