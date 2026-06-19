const test = require('node:test');
const assert = require('node:assert/strict');
const { mapProduct } = require('../services/openBeautyFactsService');

test('mapProduct normalizes Open Beauty Facts product payloads', () => {
    const product = mapProduct('3560070791460', {
        status: 1,
        product: {
            product_name: 'Gentle Face Cream',
            brands: 'Demo Brand, Parent Company',
            image_front_url: 'https://images.openbeautyfacts.org/demo.jpg',
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
    assert.equal(product.imageURL, 'https://images.openbeautyfacts.org/demo.jpg');
    assert.deepEqual(
        product.ingredients.map((ingredient) => ingredient.name),
        ['Aqua', 'Glycerin', 'fragrance']
    );
    assert.equal(product.ingredients[2].riskLevel, 'high');
});

test('mapProduct returns null when Open Beauty Facts has no matching product', () => {
    assert.equal(mapProduct('0000000000000', { status: 0 }), null);
});
