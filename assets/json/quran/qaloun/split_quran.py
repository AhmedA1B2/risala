import json
import os
import re
from collections import defaultdict

# مسار السكربت
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# اسم الملف الأصلي
INPUT_FILE = os.path.join(BASE_DIR, "qaloun.json")

# مجلد الإخراج
OUTPUT_FOLDER = os.path.join(BASE_DIR, "surahs_qaloon_clean")

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# دالة تنظيف الآية من الرموز الخاصة في النهاية
def clean_aya_text(text):
    text = text.strip()

    # حذف الرموز الخاصة مثل ﰀ ﰁ ﰂ ...
    text = re.sub(r'[\ufc00-\ufcff]+$', '', text)

    return text.strip()

# قراءة الملف
with open(INPUT_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)

# تجميع الآيات
surahs = defaultdict(list)

for verse in data:
    surah_number = verse["sura_no"]
    verse_number = verse["aya_no"]
    content = clean_aya_text(verse["aya_text"])

    formatted_verse = {
        "surah_number": surah_number,
        "verse_number": verse_number,
        "content": content
    }

    surahs[surah_number].append(formatted_verse)

# إنشاء 114 ملف
for surah_number in range(1, 115):
    surah_verses = surahs.get(surah_number, [])

    output_path = os.path.join(OUTPUT_FOLDER, f"{surah_number}.json")

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(surah_verses, f, ensure_ascii=False, indent=4)

print("تم تنظيف الآيات وتقسيم 114 سورة بنجاح ✅")
