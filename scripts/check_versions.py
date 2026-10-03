from pathlib import Path
import re,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
version=(root/'VERSION').read_text().strip()
assert re.fullmatch(r'\d+\.\d+\.\d+',version),'VERSION invalide'
ns={'m':'http://maven.apache.org/POM/4.0.0'}
pom=ET.parse(root/'backend/pom.xml').getroot()
assert pom.find('m:version',ns).text==version,'Version Maven différente'
mobile=(root/'mobile/pubspec.yaml').read_text()
assert re.search(r'^version: '+re.escape(version)+r'\+\d+$',mobile,re.M),'Version Flutter différente'
api=(root/'backend/src/main/java/sn/campustasks/controller/ApiController.java').read_text(encoding='utf-8')
assert '"version","'+version+'"' in api,'Version health différente'
print('Versions cohérentes : '+version)
