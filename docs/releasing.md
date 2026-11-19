# Daedalus mirror releases

1. Copy `custom_components/delonghi_daedalus/` and `LICENSE` from a reviewed commit on [the upstream default branch](https://github.com/sk7n4k3d/delonghi-ha). Remove files deleted upstream and record the upstream commit in the mirror commit.
2. Keep the component version from upstream and use the matching `vX.Y.Z` tag. Keep `hacs.json` configured to use `delonghi_daedalus.zip`.
3. Open a mirror pull request. Its validation workflow checks the manifests and translations and builds the same ZIP as the tag workflow. To build it locally, run `scripts/package-release.sh vX.Y.Z` from the mirror root. Confirm that the ZIP includes the component manifest, bundled icon and MIT license.
4. Merge the reviewed pull request and verify the HACS and hassfest workflows pass on `main`. Tag the validated mirror commit with the matching `vX.Y.Z` tag. For a prerelease, upstream's manifest and the proposed tag must use the same suffix, such as `vX.Y.Z-rc.1`. The release workflow attaches the ZIP with the component manifest at its root.
5. Check the published asset in separate Home Assistant configurations. Test a fresh install and an upgrade from the prior version in Marketplace on Home Assistant 2026.11+ and in HACS where still supported, including the minimum Home Assistant version in `hacs.json`. Restart after the upgrade and verify the integration opens its configuration form.

The [official HACS Action](https://github.com/hacs/action) validates the mirror with the `integration` category. The component provides `brand/icon.png` for the branding check.

[HACS default listing](https://hacs.xyz/docs/publish/include/) is a separate submission. Home Assistant [Marketplace](https://www.home-assistant.io/integrations/marketplace/) uses the same catalog. After publishing the release, add `sk7n4k3d/delonghi-daedalus-ha` to the [`integration` list](https://github.com/hacs/default/blob/master/integration) and include links to the release and the passing HACS and hassfest action runs in the catalog pull request. Until listed, users add the mirror as a custom repository. Marketplace requires a connected GitHub account to add custom repositories.
