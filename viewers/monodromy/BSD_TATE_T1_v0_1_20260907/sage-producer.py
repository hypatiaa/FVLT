"""Separate-host producer scaffold; NOT live-validated on the Windows build host.

Run under `sage -python sage-producer.py` with {"ainvs":[five rational strings],"p":"37"}
on stdin. Generic Tate is explicit. This emits a SOURCE_REPORT, not a T1 certificate.
The receiving seat must pin the reported Sage distribution/source hashes before comparison.
"""
import hashlib, inspect, json, re, sys
from pathlib import Path

def main():
    from sage.all import EllipticCurve, QQ, ZZ
    from sage.env import SAGE_VERSION
    from sage.schemes.elliptic_curves import ell_local_data, weierstrass_morphism
    def unique(pairs):
        out = {}
        for k, v in pairs:
            if k in out:
                raise ValueError('Duplicate key')
            out[k] = v
        return out
    raw = sys.stdin.buffer.read(20001)
    if len(raw) > 20000:
        raise ValueError('Input work cap')
    q = json.loads(raw.decode('utf-8'), object_pairs_hook=unique)
    if set(q) != {'ainvs', 'p'} or len(q['ainvs']) != 5:
        raise ValueError('Expected five coefficients and prime')
    for s in q['ainvs']:
        if not isinstance(s, str) or len(s)>194 or not re.fullmatch(r'(0|-?[1-9][0-9]*)(/[1-9][0-9]*)?',s) or str(QQ(s)) != s:
            raise ValueError('Canonical rational required')
    if not isinstance(q['p'],str) or not re.fullmatch(r'[1-9][0-9]{0,3}',q['p']):
        raise ValueError('Canonical bounded prime required')
    p = ZZ(q['p'])
    if p < 2 or p > 1009 or not p.is_prime(proof=True):
        raise ValueError('Prime proof domain 2..1009')
    E = EllipticCurve(QQ, list(map(QQ,q['ainvs'])))
    data = E.local_data(p, algorithm='generic', proof=True)
    F = data.minimal_model()
    iso = E.isomorphism_to(F)
    def pin(module):
        file = Path(inspect.getsourcefile(module))
        return {'file':file.name,'sha256':hashlib.sha256(file.read_bytes()).hexdigest()}
    out = {'schema':'BSD_T1_SAGE_SOURCE_REPORT_V1','status':'SOURCE_REPORT','sageVersion':SAGE_VERSION,
        'algorithm':'generic','proof':True,'inputBytesSha256':hashlib.sha256(raw).hexdigest(),
        'producerSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'modulePins':[pin(ell_local_data),pin(weierstrass_morphism)],'request':q,
        'localModel':list(map(str,F.a_invariants())),
        'sourceToTargetUrst':dict(zip(['u','r','s','t'],map(str,iso.tuple()))),
        'discriminantValuation':str(data.discriminant_valuation()),'conductorExponent':str(data.conductor_valuation()),
        'kodaira':str(data.kodaira_symbol()),'tamagawaNumber':str(data.tamagawa_number()),
        'badReductionType':None if data.bad_reduction_type() is None else str(data.bad_reduction_type()),
        'globalMinimality':'NOT_REQUESTED','traceInstrumentation':'NOT_IMPLEMENTED'}
    print(json.dumps(out,indent=2))

if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(str(error),file=sys.stderr)
        sys.exit(1)
