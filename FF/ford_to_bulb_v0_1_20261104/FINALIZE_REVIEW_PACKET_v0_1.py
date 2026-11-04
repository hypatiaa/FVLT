"""Assemble a hash-pinned proposed review packet; no mathematical tool execution."""
from pathlib import Path
import json,hashlib,shutil
root=Path(__file__).resolve().parent;p=root/'freeze_packet_v0_1'
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(f,o):text(f,json.dumps(o,indent=2)+'\n')
template=json.loads((p/'JOB_TEMPLATE_v0_1.json').read_text(encoding='utf-8'))
index=json.loads((p/'TARGET_INDEX_v0_1.json').read_text(encoding='utf-8'))
static=json.loads((p/'STATIC_VALIDATION_v0_1.json').read_text(encoding='utf-8'))
assert static['status']=='PASS_STATIC_AND_PURE_TEXT_GUARDS_ONLY' and not static['mathematical_result']
save(p/'INPUT_FREEZE_PROPOSED_v0_1.json',{'status':'PROPOSED_FOR_MANAGER_REVIEW_NOT_ACCEPTED','date':'2026-11-04','accepted_order_sha256':'d28dfd0ebbc49d1677e4765b492ec35450b7c842054b85bc7834c6d2f124b2d8','owner_acceptance_sha256':'6e5c8b61ed4bd4bf6467bec2277a5cf47eb6ee7010b86a1a1daf418bcb8ec554','library':'/home/saphir/rule30_theorem_library/v23','library_expected':template['library_expected'],'lean_executable_sha256':template['lean_executable_sha256'],'mathlib_rev':template['mathlib_rev'],'definitions_sha256':template['definitions_sha256'],'headers_sha256':template['headers_sha256'],'target_index_sha256':template['target_index_sha256'],'checker_sha256':template['checker_sha256'],'runner_sha256':template['runner_sha256'],'unbound_template_sha256':sha(p/'JOB_TEMPLATE_v0_1.json'),'actual_import_closure_sha256':sha(p/'INPUT_LIBRARY_SOURCE_CLOSURE_v0_1.json'),'data_named_targets':31,'public_targets':33,'B6':'EXCLUDED_SEPARATE_GATE','Lean_elaboration':'NOT_RUN','Sage_run':'NOT_RUN','execution_go':'Existing Robin FF4 go relayed firsthand by root and bus1557; manager gates remain','kernel_standing':'NO_ADOPTION'})
save(p/'CONCRETE_JOB_EXAMPLE_v0_1.json',{'status':'EXAMPLE_ONLY_NOT_DISPATCHABLE','phase':'FF4_COMBINATORIAL','module':index['data_module'],'mode':'compile','run_id':'DataExampleNotDispatched','template_sha256':sha(p/'JOB_TEMPLATE_v0_1.json'),'attempt_folder':'EXAMPLE_NOT_STAGED','source_sha256':{index['data_module']+'.lean':template['definitions_sha256']},'dependency_olean_sha256':{},'prerequisite_receipt_sha256':{},'signature_comparison_receipt_file':'EXAMPLE_COMPARISON_NOT_ACCEPTED.json','signature_comparison_receipt_sha256':'UNBOUND','deadline_file':'EXAMPLE_DEADLINE_NOT_ARMED.json'})
save(p/'REVIEW_ACCEPTANCE_EXAMPLE_v0_1.json',{'status':'EXAMPLE_ONLY_NOT_EXECUTION_ACCEPTANCE','input_signature_acceptance':'','template_acceptance':'','runner_sha256':template['runner_sha256'],'bound_template_file':'NONE_UNBOUND','bound_template_sha256':'','accepted_job_sha256':[],'reviewed_files':{},'note':'After manager acceptance, stage every manifest entry under a pinned freeze_packet_v0_1 subtree and include their hashes plus manifest in reviewed_files; only then create a real runtime REVIEW_ACCEPTANCE.json. No such file is included here.'})
text(p/'inputs/EXECUTION_GO_RELAY_20261104.md','''# FF-4 firsthand go relay

2026-11-04. Root coordination chat 01a177de-b5f1-7ad3-895d-cbdb54bee260 relayed Robin's direct instruction, "go for ff-4", to the formalization owner. Bus #1557 records the firsthand authorization and its workflow boundary. This authorizes progress through FF-4's review and execution gates; it does not pre-accept an order, definitions, headers, runner or concrete job. Existing authorization persists after the reviewed scope is settled; no duplicate human go is requested.

The owner accepted exact work order v0.2 in OWNER_ACCEPTANCE_v0_2.md. This proposed packet still needs skeleton's independent input/signature/runner/policy decision. B6 remains separately gated. No Lean/Sage run, bound runtime, host reservation or execution job is supplied by this relay.
''')
shutil.copyfile(Path(__file__),p/Path(__file__).name)
allfiles=sorted(f for f in p.rglob('*') if f.is_file() and f.name not in {'PACKET_MANIFEST_v0_1.json','SHA256SUMS.txt'})
text(p/'SHA256SUMS.txt',''.join(sha(f)+'  '+f.relative_to(p).as_posix()+'\n' for f in allfiles))
files=[{'file':f.relative_to(p).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in sorted(p.rglob('*')) if f.is_file() and f.name!='PACKET_MANIFEST_v0_1.json']
save(p/'PACKET_MANIFEST_v0_1.json',{'status':'PROPOSED_FF4_INPUT_SIGNATURE_RUNNER_REVIEW_NOT_EXECUTION_ACCEPTANCE','date':'2026-11-04','files':files,'public_targets':33,'data_declarations':31,'Lean_invoked':False,'Sage_invoked':False,'runner_entrypoint_executed':False,'policies':'All-match posting and fresh proof-only retries requested for FF4 own manager decision'})
print(json.dumps({'manifest_sha256':sha(p/'PACKET_MANIFEST_v0_1.json'),'entries':len(files),'definitions_sha256':template['definitions_sha256'],'headers_sha256':template['headers_sha256'],'runner_sha256':template['runner_sha256'],'template_sha256':sha(p/'JOB_TEMPLATE_v0_1.json'),'input_freeze_sha256':sha(p/'INPUT_FREEZE_PROPOSED_v0_1.json'),'target_index_sha256':sha(p/'TARGET_INDEX_v0_1.json'),'static_validation_sha256':sha(p/'STATIC_VALIDATION_v0_1.json')},indent=2))
