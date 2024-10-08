db = db.getSiblingDB('ecommerce');

db.createCollection('products');

db.createUser({
  user: 'dev',
  pwd: 'dev123',
  roles: [
    { role: 'readWrite', db: 'ecommerce' }
  ]
});
