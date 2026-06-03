import json
import re

INPUT_FILE = r"C:/Users/MSII/Desktop/risala/risala/assets/json/quran/qaloun/qaloun.json"
OUTPUT_FILE = r"C:/Users/MSII/Desktop/risala/risala/assets/json/quran/qaloun/quran_simplified.json"

# إزالة التشكيل والعلامات القرآنية
def remove_diacritics(text):
    arabic_diacritics = re.compile(r'''
        [\u0610-\u061A]
        |[\u064B-\u065F]
        |[\u0670]
        |[\u06D6-\u06ED]
    ''', re.VERBOSE)

    text = re.sub(arabic_diacritics, '', text)

    # إزالة رموز المصحف والخط العثماني
    text = re.sub(r'[\uF000-\uF8FF]', '', text)
    text = re.sub(r'[\uFB50-\uFDFF]', '', text)
    text = re.sub(r'[\uFE70-\uFEFF]', '', text)

    # إزالة الرموز الشائعة
    text = re.sub(r'[۞۩]', '', text)

    return text


# توحيد الحروف
def normalize_arabic(text):
    replacements = {
        'أ': 'ا',
        'إ': 'ا',
        'آ': 'ا',
        'ٱ': 'ا',
        'ؤ': 'و',
        'ئ': 'ي',
        'ة': 'ه',
        'ى': 'ي',
    }

    for old, new in replacements.items():
        text = text.replace(old, new)

    return text


# تنظيف النص بالكامل
def clean_text(text):
    text = remove_diacritics(text)
    text = normalize_arabic(text)

    # إبقاء الحروف العربية والمسافات فقط
    text = re.sub(r'[^\u0621-\u064A\s]', ' ', text)

    # حذف المسافات الزائدة
    text = re.sub(r'\s+', ' ', text).strip()

    return text


with open(INPUT_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)

result = []

for verse in data:
    result.append({
        "surah_number": verse["sura_no"],
        "verse_number": verse["aya_no"],
        "content": clean_text(verse["aya_text"])
    })

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, indent=4)

print(f"Saved to {OUTPUT_FILE}")