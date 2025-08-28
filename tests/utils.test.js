const soma = require('../src/utils');

test('deve somar dois números corretamente', () => {
  expect(soma(2, 3)).toBe(5);
});
