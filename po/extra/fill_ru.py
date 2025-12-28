import re

with open('ru.back', 'r', encoding='utf-8') as f:
    content = f.read()

translations = {}
current_msgid = None
for line in content.split('\n'):
    if line.startswith('msgid "'):
        current_msgid = line[7:-1]
    elif line.startswith('msgstr "') and current_msgid:
        msgstr = line[8:-1]
        translations[current_msgid] = msgstr
        current_msgid = None

with open('ru.po', 'r', encoding='utf-8') as f:
    po_content = f.read()

def replace_empty_msgstr(match):
    msgid = match.group(1)
    if msgid in translations:
        return f'msgid "{msgid}"\nmsgstr "{translations[msgid]}"'
    else:
        return match.group(0)

po_content = re.sub(r'msgid "([^"]*)"\nmsgstr ""', replace_empty_msgstr, po_content)

with open('ru.po', 'w', encoding='utf-8') as f:
    f.write(po_content)

print("Done")
