from pathlib import Path
import hashlib,json
p=Path(__file__).resolve().parent/'final_source_packet_v0_1'
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
manifest=p/'FINAL_PACKET_MANIFEST_v0_1.json'
assert sha(manifest)=='ad0fd106447de512d1d8123a5ff3cac2dbcad639c9c9625d1f2560bed28f93d6'
entries=json.loads(manifest.read_text())['entries'];bad=[]
for e in entries:
 f=p/e['path'];f.resolve().relative_to(p.resolve())
 if not f.is_file() or f.stat().st_size!=e['bytes'] or sha(f)!=e['sha256']:bad.append(e['path'])
print(json.dumps({'status':'TRANSPORT_HASH_CHECK_ONLY_NOT_INDEPENDENT_PROOF_AUDIT','entries':len(entries),'mismatches':bad,'manifest_sha256':sha(manifest)},indent=2))
assert not bad
