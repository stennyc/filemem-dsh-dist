#!/usr/bin/env node
// filemem-dsh installer for environments without curl/wget (the dsh-Go
// phone proot userland: node 24 is preinstalled, the download tools are
// not). Fetches the tarball + SHA256SUMS from the dist repo's releases
// branch over https (node's global fetch), verifies the checksum with
// node:crypto (no sha256sum binary needed), and extracts with tar.
//
// Usage:  node install-node.mjs [rc1host]
//   no arg      = the full build (rc.5-generation hosts)
//   rc1host     = the rc.1-host build (dsh-Go phone engine)
// The target platform is derived from the running node (arch + platform).
import { spawnSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const BASE = "https://raw.githubusercontent.com/stennyc/filemem-dsh-dist/releases";
const VARIANT = process.argv[2] === "rc1host" ? "rc1host" : "";

// platform -> the releases-branch target name
function targetName() {
  const p = process.platform, a = process.arch;
  if (p === "linux" && (a === "x64" || a === "amd64")) return "linux-x64";
  if (p === "linux" && (a === "arm64" || a === "aarch64")) return "linux-arm64";
  if (p === "darwin" && a === "arm64") return "darwin-arm64";
  if (p === "darwin" && a === "x64") return "darwin-x64";
  if (p === "win32" && (a === "x64" || a === "arm64")) return "windows-x64";
  throw new Error("unsupported platform: " + p + "-" + a + " (the releases branch ships: linux-x64, linux-arm64, darwin-x64, darwin-arm64, windows-x64)");
}
const TARGET = targetName();

async function main() {
  // resolve the newest version on the branch (the rc1host variant pairs
  // with the same version line)
  const sumsUrl = BASE + "/SHA256SUMS";
  const sums = (await (await fetch(sumsUrl)).text()).trim().split("\n");
  const versions = [...new Set(sums.map((l) => {
    const m = l.match(/filemem-dsh-([0-9][0-9.]*)(-rc1host)?-(?:linux|darwin|windows)-[\w]+\.tar\.gz/);
    return m ? m[1] : null;
  }).filter(Boolean))].sort().pop();
  const file = "filemem-dsh-" + versions + "-" + VARIANT + TARGET + ".tar.gz";
  const line = sums.find((l) => l.trimEnd().endsWith("  " + file) || l.includes("  " + file));
  if (!line) { console.error("no checksum row for " + file + " — check the variant flag"); process.exit(1); }
  const want = line.trim().split(/\s+/)[0];

  console.log("fetching " + file + " ...");
  const buf = Buffer.from(await (await fetch(BASE + "/" + file)).arrayBuffer());
  const got = crypto.createHash("sha256").update(buf).digest("hex");
  if (got !== want) { console.error("CHECKSUM MISMATCH for " + file); process.exit(1); }
  console.log(file + ": checksum ok");

  const tmp = path.join(os.tmpdir(), file);
  fs.writeFileSync(tmp, buf);
  const r = spawnSync("tar", ["-xzf", tmp], { stdio: "inherit" });
  if (r.status !== 0) { console.error("tar extraction failed (is tar available in this environment?)"); process.exit(1); }
  fs.unlinkSync(tmp);
  const dir = "filemem-dsh-" + versions;
  console.log("");
  console.log("extracted: " + path.join(process.cwd(), dir));
  console.log("next (in your terminal):  cp -r " + dir + " /root/.dsh/dsh-go/plugins/filemem-rc1");
  console.log("     then:  dsh plugin --profile <your-app-profile> add /root/.dsh/dsh-go/plugins/filemem-rc1");
}
main().catch((e) => { console.error(e.message || e); process.exit(1); });
