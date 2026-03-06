# Releasing MUMPS.IO (MIO)

This project uses Semantic Versioning: `MAJOR.MINOR.PATCH`.

## Preparation
1. Update `VERSION`
2. Update `CHANGELOG.md` under `[Unreleased]` and move entries under the new version heading
3. Commit changes:
   - `git commit -am "Release vX.Y.Z"`

## Tag and publish
1. `git tag vX.Y.Z`
2. `git push origin vX.Y.Z`

GitHub Actions will create a GitHub Release automatically from the tag.

## Hotfixes
- Branch from the last tag
- Bump patch version
- Tag + push
