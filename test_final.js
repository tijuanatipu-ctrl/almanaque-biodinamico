const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const context = await browser.createContext();
  const page = await context.newPage();

  console.log('Loading deployed page...');
  await page.goto('https://tijuanatipu-ctrl.github.io/almanaque-biodinamico/BIODINAMICO%20WEB/almanaque_biodinamico.html', { waitUntil: 'networkidle' });

  console.log('\n📋 VERIFICATION RESULTS:\n');

  // Check if date number is centered
  const dateNum = await page.locator('.date-num').first();
  const dateWrap = await page.locator('.date-wrap').first();
  const dateNumText = await dateNum.textContent();
  const justifyContent = await dateWrap.evaluate(el => window.getComputedStyle(el).justifyContent);
  console.log(`✅ Date number: ${dateNumText}`);
  console.log(`✅ Date wrap justify-content: ${justifyContent}`);

  // Get weather description
  const weatherDesc = await page.locator('#weather-description').first();
  const weatherText = await weatherDesc.textContent();
  console.log(`✅ Weather description: ${weatherText?.substring(0, 100)}...`);

  // Check for "estrellado" logic presence in page
  const pageContent = await page.content();
  const hasEstrelladoLogic = pageContent.includes('estrellado');
  console.log(`✅ Has "estrellado" logic: ${hasEstrelladoLogic}`);

  await browser.close();
  console.log('\n✨ Verification complete!');
})();
