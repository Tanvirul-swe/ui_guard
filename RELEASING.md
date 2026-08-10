# Release Checklist (pub.dev)

Use this checklist before creating a GitHub Release so `Publish to pub.dev` can run successfully.

## 1) One-time repository setup

- [ ] Configure **pub.dev Trusted Publisher** for this repository.
  - pub.dev package → Admin → Publishing → Trusted publishers.
  - Add your GitHub repository as a trusted publisher.
- [ ] In GitHub repo settings, create environment **`pub.dev`**.
- [ ] (Recommended) Protect `main` branch and require CI checks.

---

## 2) Prepare the release PR

- [ ] Update `pubspec.yaml` version (example: `1.1.1`).
- [ ] Add release notes section to `CHANGELOG.md` (same version).
- [ ] Update docs/examples if API changed.
- [ ] Ensure `.github/workflows/ci.yml` passes in PR.

---

## 3) Merge and create release tag

After merging PR to `main`:

- [ ] Create a Git tag in SemVer format:
  - `v1.1.1` for stable
  - `v1.1.1-rc.1` for pre-release
- [ ] Create a GitHub Release from that tag and click **Publish release**.

> Publishing the release triggers `.github/workflows/publish.yml`.

---

## 4) Workflow validations performed automatically

The publish workflow checks:

- [ ] Tag name matches `pubspec.yaml` version (ignoring leading `v`).
- [ ] `CHANGELOG.md` contains an entry for that version.
- [ ] `flutter analyze` and `flutter test` pass.
- [ ] `dart pub publish --dry-run` passes.
- [ ] `dart pub publish -f` runs via trusted publishing.

---

## 5) Post-publish verification

- [ ] Verify new version appears on pub.dev package page.
- [ ] Confirm README and API docs render correctly.
- [ ] Smoke-test install in a clean app:
  - `flutter pub add ui_guard`
  - Run sample integration quickly.
- [ ] Announce release notes.

---

## Rollback / Hotfix

If publish fails:

1. Inspect failed GitHub Action logs.
2. Fix issue in new PR.
3. Bump to next patch version (do not reuse published versions).
4. Tag and publish a new GitHub Release.
