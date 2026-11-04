"""Text/JSON/Python grammar and pure signature-guard tests; never runs Lean or runner main."""
import ast,hashlib,json,re
from pathlib import Path
p=Path(__file__).resolve().parent
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def main():
 index=json.loads((p/'TARGET_INDEX_v0_1.json').read_text(encoding='utf-8'))
 template=json.loads((p/'JOB_TEMPLATE_v0_1.json').read_text(encoding='utf-8'))
 data=(p/template['definitions_file']).read_bytes()
 headers=(p/template['headers_file']).read_text(encoding='utf-8')
 tree=ast.parse((p/template['runner']).read_text(encoding='utf-8'))
 assert len(index['targets'])==33 and len(index['data_axiom_targets'])==31
 assert len(re.findall(r'^theorem\s+',headers,re.M))==33
 assert not re.search(r'\b(sorry|admit|axiom|native_decide|implemented_by|unsafe|extern)\b',data.decode()+headers)
 assert ':=' not in headers
 for field,hfield in [('runner','runner_sha256'),('checker','checker_sha256'),('definitions_file','definitions_sha256'),('headers_file','headers_sha256'),('target_index_file','target_index_sha256')]:assert sha(p/template[field])==template[hfield]
 assert template['status'].startswith('PROPOSED') and template['phase']=='FF4_COMBINATORIAL'
 assert template['library'].endswith('/v23')
 assert not (p/'REVIEW_ACCEPTANCE.json').exists()
 for f in [p/template['definitions_file'],p/template['headers_file'],p/template['runner']]:assert b'\r' not in f.read_bytes() and not f.read_bytes().startswith(b'\xef\xbb\xbf')
 # Extract only this pure text-check function. No runner import, entrypoint,
 # host checks, process calls, filesystem paths or mathematical proofs execute.
 guard=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='frozen_source_check')
 class Blob:
  def __init__(self,b):self.b=b
  def read_bytes(self):return self.b
 def member(files,name):return Blob(files[name])
 env={'re':re,'member':member}
 exec(compile(ast.Module(body=[guard],type_ignores=[]),'EXTRACTED_PURE_TEXT_GUARD','exec'),env)
 check=env['frozen_source_check']
 fixtures={index['data_module']+'.lean':data}
 for module in template['module_order'][1:]:
  sigs=[t['header'] for t in index['targets'] if t['module']==module]
  # These strings test parsing only. They are never written as Lean files.
  text='import FVLTFordBulbDataV1\nopen scoped BigOperators\nnamespace FVLT.FordBulbV1\n\n'
  text+='\n'.join(h+' := by\n  skip\n' for h in sigs)
  text+='\nend FVLT.FordBulbV1\n';fixtures[module+'.lean']=text.encode()
 got=check(fixtures,fixtures,index,Blob(data))
 assert set(got)==set(t['name'] for t in index['targets']) and len(got)==33
 module='FVLTFordBulbCombinatoricsV1.lean';base=fixtures[module]
 cases={
  'changed_public_header':(module,base.replace(b'address_canonical (d :',b'address_canonical (e :',1)),
  'unknown_public_theorem':(module,base.replace(b'theorem address_canonical',b'theorem renamed_public',1)),
  'indented_public_theorem':(module,base.replace(b'theorem address_canonical',b' theorem address_canonical',1)),
  'extra_public_lemma':(module,base.replace(b'end FVLT.FordBulbV1',b'lemma extra : True := by trivial\nend FVLT.FordBulbV1')),
  'extra_public_definition':(module,base.replace(b'end FVLT.FordBulbV1',b'def extra : Nat := 0\nend FVLT.FordBulbV1')),
  'attribute_wrapper':(module,base.replace(b'theorem address_canonical',b'@[simp]\ntheorem address_canonical',1)),
  'CRLF_source':(module,base.replace(b'\n',b'\r\n')),
  'BOM_source':(module,b'\xef\xbb\xbf'+base),
  'data_guard_changed':(index['data_module']+'.lean',data.replace(b'p_pos : 0 < p',b'p_pos : 0 <= p',1)),
  'proof_separator_changed':(module,base.replace(b' := by',b' :=\nby',1)),
  'duplicate_theorem':(module,base.replace(b'end FVLT.FordBulbV1',(index['targets'][0]['header']+' := by\n  skip\nend FVLT.FordBulbV1').encode()))}
 results={}
 for name,(filename,b) in cases.items():
  altered=dict(fixtures);altered[filename]=b
  try:check(altered,altered,index,Blob(data))
  except (AssertionError,UnicodeDecodeError):results[name]='EXPECTED_REFUSAL'
  else:raise AssertionError('Negative control accepted: '+name)
 result={'status':'PASS_STATIC_AND_PURE_TEXT_GUARDS_ONLY','public_targets':33,'data_declarations':31,'positive_text_fixture':'PASS_33_HEADERS','negative_controls':results,'runner_imported':False,'runner_entrypoint_executed':False,'pure_guard_extracted_by_AST':True,'Lean_invoked':False,'Sage_invoked':False,'mathematical_result':False,'warning':'No Lean elaboration is tested; source typing and theorem proofs remain unverified'}
 (p/'STATIC_VALIDATION_v0_1.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
