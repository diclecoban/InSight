const test = require('node:test');
const assert = require('node:assert/strict');
const { mapProduct } = require('../services/openBeautyFactsService');

test('mapProduct normalizes Open Beauty Facts product payloads', () => {
    const product = mapProduct('3560070791460', {
        status: 1,
        product: {
            product_name: 'Gentle Face Cream',
            brands: 'Demo Brand, Parent Company',
            ingredients: [
                { text: 'Aqua' },
                { text: 'Glycerin' }
            ],
            ingredients_tags: ['en:glycerin', 'en:fragrance'],
            ingredients_text: 'Aqua, Glycerin, Fragrance'
        }
    });

    assert.equal(product.name, 'Gentle Face Cream');
    assert.equal(product.brand, 'Demo Brand');
    assert.equal(product.barcode, '3560070791460');
    assert.deepEqual(
        product.ingredients.map((ingredient) => ingredient.name),
        ['Aqua', 'Glycerin', 'fragrance']
    );
});

test('mapProduct returns null when Open Beauty Facts has no matching product', () => {
    assert.equal(mapProduct('0000000000000', { status: 0 }), null);
});
