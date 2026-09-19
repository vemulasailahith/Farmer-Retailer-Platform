import joblib

yield_encoder = joblib.load('models/crop_yield_encoder.pkl')
print('=== YIELD ENCODER ===')
print('Type:', type(yield_encoder))
if isinstance(yield_encoder, dict):
    for k, v in yield_encoder.items():
        if hasattr(v, 'classes_'):
            print(f'{k} classes ({len(v.classes_)}):', list(v.classes_))
        else:
            print(f'{k}:', v)
elif hasattr(yield_encoder, 'categories_'):
    print('categories_:', yield_encoder.categories_)
elif hasattr(yield_encoder, 'classes_'):
    print('classes_:', yield_encoder.classes_)

price_pre = joblib.load('models/price_preprocessing.pkl')
print('\n=== PRICE PREPROCESSING ===')
for k, v in price_pre.items():
    if k == 'frequency_mappings':
        print('frequency_mappings keys:', list(v.keys()))
        for col, mapping in v.items():
            if col == 'Commodity':
                print(f'{col} keys ({len(mapping)}):', list(mapping.keys()))
            elif col in ('State', 'District'):
                print(f'{col} sample ({len(mapping)}):', list(mapping.keys())[:10])
    elif isinstance(v, list):
        print(f'{k}:', v)
    else:
        print(f'{k}:', type(v))
