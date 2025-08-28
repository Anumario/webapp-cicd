const request = require('supertest');
const app = require('../src/app');

describe('GET /hello', () => {
  it('deve retornar Hello World!', async () => {
    const res = await request(app).get('/hello');
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('Hello World!');
  });
});
