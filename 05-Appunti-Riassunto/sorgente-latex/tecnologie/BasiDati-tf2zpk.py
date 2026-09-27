import sys,numpy as np
from scipy.signal import tf2zpk
bs,lb,rb=chr(92),chr(123),chr(125)
fmt=lambda arr:",".join([str(round(c.real,6)) if abs(round(c.imag,6))<1e-5 else str(round(c.real,6))+("+"+str(round(c.imag,6)) if round(c.imag,6)>=0 else str(round(c.imag,6)))+"i" for c in arr])
try: num=[float(x) for x in sys.argv[1].split(",")]; den=[float(x) for x in sys.argv[2].split(",")]; z,p,k=tf2zpk(num,den); nl=chr(10); f=open(sys.argv[3],"w"); f.write(bs+"def"+bs+"zpkGain"+lb+format(k,".6f")+rb+nl); f.write(bs+"def"+bs+"zpkZeros"+lb+fmt(z)+rb+nl); f.write(bs+"def"+bs+"zpkPoles"+lb+fmt(p)+rb+nl); f.close()
except Exception as e: sys.stderr.write(str(e))
