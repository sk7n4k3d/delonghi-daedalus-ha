# Daedalus mirror releases

1. Copy the Daedalus component from the reviewed upstream commit. Record the upstream commit in the mirror commit.
2. Set `custom_components/delonghi_daedalus/manifest.json` to the version you intend to tag. Keep `hacs.json` configured to use `delonghi_daedalus.zip`.
3. Open a mirror pull request. Its validation workflow checks the manifests and translations and builds the same ZIP as the tag workflow. To build it locally, run `scripts/package-release.sh vX.Y.Z` from the mirror root.
4. Tag the reviewed mirror commit with the matching `vX.Y.Z` tag. A tag with a suffix such as `vX.Y.Z-rc.1` publishes a prerelease. The release workflow attaches the ZIP with the component manifest at its root.
5. Check the published asset in separate Home Assistant configurations. Test a fresh install and an upgrade from the prior version in Marketplace on Home Assistant 2026.11+ and in HACS where still supported, including the minimum Home Assistant version in `hacs.json`. Restart after the upgrade and verify the integration opens its configuration form.

The [official HACS Action](https://github.com/hacs/action) validates the mirror with the `integration` category. Its current validator accepts a bundled `brand/icon.png` or an entry in the [Home Assistant Brands directory](https://brands.home-assistant.io/domains.json). The mirror skips that check until it carries its local icon.

[HACS default listing](https://github.com/hacs/default) is a separate submission. Home Assistant [Marketplace](https://www.home-assistant.io/integrations/marketplace/) uses the same catalog. Until listed, users add the mirror as a custom repository. Marketplace requires a connected GitHub account to add custom repositories. Marketplace installs ZIP release assets through its GitHub-backed path.
