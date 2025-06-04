import json
from collections import OrderedDict


if __name__ == "__main__":
    updated_data = []

    with open("cellphonedata.json", 'r', encoding='utf-8') as f:
        data = json.load(f)

    for i, item in enumerate(data, start=1):
        ordered_item = OrderedDict()
        ordered_item['id'] = i

        for k, v in item.items():
            ordered_item[k] = v

        updated_data.append(ordered_item)

    result = json.dumps(updated_data, indent=2)

    with open("cellphonedata_with_ids.json", 'w', encoding='utf-8') as f:
        f.write(result)
