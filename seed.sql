-- =====================================================================
-- OPTIONAL: demo products with PLACEHOLDER images so the website is not empty
-- while you are testing. Run AFTER schema.sql.
-- Delete them later from Admin -> All Products, then add your real jerseys.
-- =====================================================================

insert into public.products
  (slug, name, description, specifications, club, category_id, price, sale_price, sizes, stock,
   is_featured, is_new_arrival, is_best_seller, images)
values
(
  'demo-real-madrid-home-2025-26',
  'Real Madrid Home Jersey 2025/26',
  'Classic all-white home kit with a clean modern collar. Lightweight, breathable and made for match day or everyday wear.',
  E'Fabric: Breathable polyester\nFit: Regular\nVersion: Fan edition\nSeason: 2025/26',
  'Real Madrid',
  (select id from public.categories where slug = 'club-jerseys'),
  4500, 3800, array['S','M','L','XL','XXL'], 12,
  true, true, true,
  array['https://placehold.co/800x1000/1c1c1c/ffffff.png?text=Real+Madrid+Home','https://placehold.co/800x1000/262626/e10600.png?text=Back+View']
),
(
  'demo-barcelona-home-2025-26',
  'FC Barcelona Home Jersey 2025/26',
  'Bold blaugrana stripes with premium stitched detailing. A must-have for every Cule.',
  E'Fabric: Breathable polyester\nFit: Regular\nVersion: Fan edition\nSeason: 2025/26',
  'FC Barcelona',
  (select id from public.categories where slug = 'club-jerseys'),
  4500, null, array['S','M','L','XL'], 8,
  true, true, false,
  array['https://placehold.co/800x1000/1c1c1c/e10600.png?text=Barcelona+Home']
),
(
  'demo-manchester-united-home',
  'Manchester United Home Jersey',
  'Red Devils red with a sharp collar and soft-touch fabric. Wear your passion loud.',
  E'Fabric: Breathable polyester\nFit: Regular\nVersion: Fan edition',
  'Manchester United',
  (select id from public.categories where slug = 'club-jerseys'),
  4200, 3500, array['M','L','XL','XXL'], 5,
  false, false, true,
  array['https://placehold.co/800x1000/1c1c1c/ffffff.png?text=Man+United+Home']
),
(
  'demo-argentina-home',
  'Argentina Home Jersey',
  'Sky-blue and white stripes. The jersey of the champions.',
  E'Fabric: Breathable polyester\nFit: Regular\nVersion: Fan edition',
  'Argentina',
  (select id from public.categories where slug = 'national-teams'),
  4300, null, array['S','M','L','XL','XXL'], 10,
  true, false, true,
  array['https://placehold.co/800x1000/1c1c1c/ffffff.png?text=Argentina+Home']
),
(
  'demo-brazil-retro-1998',
  'Brazil Retro 1998 Jersey',
  'Iconic yellow retro classic for the true football romantics.',
  E'Fabric: Soft cotton-blend\nFit: Relaxed\nVersion: Retro reproduction',
  'Brazil',
  (select id from public.categories where slug = 'retro-classics'),
  5000, 4400, array['M','L','XL'], 3,
  false, true, false,
  array['https://placehold.co/800x1000/1c1c1c/e10600.png?text=Brazil+Retro+98']
),
(
  'demo-liverpool-away',
  'Liverpool Away Jersey',
  'Sleek away kit built for the Kop and beyond.',
  E'Fabric: Breathable polyester\nFit: Regular\nVersion: Fan edition',
  'Liverpool',
  (select id from public.categories where slug = 'club-jerseys'),
  4400, null, array['S','M','L'], 0,
  false, false, false,
  array['https://placehold.co/800x1000/1c1c1c/ffffff.png?text=Liverpool+Away']
)
on conflict (slug) do nothing;

-- Mark the last demo item as sold out so you can see how that looks.
update public.products set is_sold_out = true where slug = 'demo-liverpool-away';
