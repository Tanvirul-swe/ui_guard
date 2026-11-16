# Release Checklist (pub.dev)

Use this checklist to publish a new version of `ui_guard` to pub.dev.

## 1) Prepare the release

- [ ] Update `pubspec.yaml` version (e.g. `1.2.0`).
- [ ] Add release notes section to `CHANGELOG.md` for the version.
- [ ] Update docs and examples if API changed.
- [ ] Ensure all tests and analysis pass locally:
  ```bash
  flutter analyze
  flutter test --exclude-tags unstable
  ```

---

## 2) Verify package before publishing

Run a dry-run check from the root directory:

```bash
dart pub publish --dry-run
```

Ensure there are **0 warnings** and **0 errors**.

---

## 3) Publish to pub.dev

Publish directly using the Dart CLI:

```bash
dart pub publish
```

*(If prompted, complete the one-time browser login to authorize your pub.dev account).*

---

## 4) Tag the release on GitHub

After publishing:

- [ ] Create a Git tag in SemVer format:
  ```bash
  git tag v1.2.0
  git push origin v1.2.0
  ```
- [ ] Create a GitHub Release with the tag and copy the release notes from `CHANGELOG.md`.

---

## 5) Post-publish verification

- [ ] Verify new version appears on [pub.dev/packages/ui_guard](https://pub.dev/packages/ui_guard).
- [ ] Confirm README and API documentation render correctly.
- [ ] Smoke-test installation in a clean project:
  ```bash
  flutter pub add ui_guard
  ```
