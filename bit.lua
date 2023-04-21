----------------------

local _VERSION, packageName, packageAuthor, packageRepository =
  '0.1.0', 'PureLuaBit32', 'Expo', {
    url = 'https://github.com/Exponential-Workload/plb/tree/master',
    type = 'git',
  }
local packageMetadata = {
  _TYPE = 'module',
  _NAME = packageName,
  _VERSION = _VERSION,
  _REPOSITORY = packageRepository,
  name = packageName,
  description = 'Pure Lua implementation of bit32 library',
  author = packageAuthor,
  license = 'MIT',
  homepage = 'https://bit.astolfo.gay',
  repository = packageRepository,
}

----------------------

local selfTest = true
local native = selfTest and (bit or bit32)

----------------------

local pow, bor, band, bnot, bxor, lshift, rshift

----------------------

pow = function(base, exponent)
  if exponent == 1 then
    return base
  elseif exponent == 0 then
    return 1
  else
    return base * pow(base, exponent - 1)
  end
end
bor = function(x, y)
  local result = 0
  local p = 1
  while x > 0 or y > 0 do
    if x % 2 + y % 2 > 0 then
      result = result + p
    end
    x = math.floor(x / 2)
    y = math.floor(y / 2)
    p = p * 2
  end
  return result
end
band = function(a, b)
  local result = 0
  local bitval = 1
  while a > 0 and b > 0 do
    if a % 2 == 1 and b % 2 == 1 then
      result = result + bitval
    end
    bitval = bitval * 2
    a = math.floor(a / 2)
    b = math.floor(b / 2)
  end
  return result
end
bnot = function(n)
  local mask = 0xffffffff
  local result = 0
  local bitval = 1
  for i = 0, 31 do
    if n % 2 == 0 then
      result = result + bitval
    end
    n = math.floor(n / 2)
    bitval = bitval * 2
  end
  return result
end
bxor = function--[[(a, b)
  local res = bor(band(bnot(a), b), band(a, bnot(b)))
  return res
end]](a, b)
  local p, res = 1, 0
  while a > 0 and b > 0 do
    local ra, rb = a % 2, b % 2
    if ra ~= rb then
      res = res + p
    end
    p, a, b = p * 2, math.floor(a / 2), math.floor(b / 2)
  end
  res = res + a * p + b * p
  return res
end
lshift = function(a, b)
  return (a * pow(2, b)) % pow(2, 32)
end
rshift = function(x, by)
  return math.floor(x / pow(2, by))
end

----------------------

local polyfill = {
  pow = pow,
  bor = bor,
  band = band,
  bnot = bnot,
  bxor = bxor,
  lshift = lshift,
  rshift = rshift,
}

----------------------

if selfTest then
  local powLoadstr = (load or loadstring) [[return function(a, b)
  return a ^ b
end]]() or function() end
  local test = function(min, max, step)
    for a = min, max, step do
      for b = min, max, step do
        local test = function(n, f)
          local x, y = ((native)[n] or f)(a, b), (polyfill[n])(a, b)
          if x ~= y then
            error(
              'Function missmatch: '
                .. n
                .. '('
                .. tostring(a)
                .. ','
                .. tostring(b)
                .. ') -> bit32('
                .. tostring(x)
                .. ') ~= polyfill('
                .. tostring(y)
                .. ')'
            )
          end
        end
        print('test', a, b)
        test 'bor'
        test 'band'
        test 'bnot'
        test 'bxor'
        -- prevent shifting too far causing errors with -nan where l/rshift return 0
        if b < 64 or bit32.lshift(a, b) > 0 then
          test 'lshift'
        end
        test 'rshift'
        -- my pow has more accuracy than pure lua pow
        local powVal = powLoadstr(a, b)
        if powVal < 1e+10 then
          test('pow', function()
            return powVal
          end)
        end
      end
    end
  end
  test(0, 255, 1)
  test(1, 512, 2)
  test(1, 1024, 8)
  test(1, 16384, 64)
  test(1, 32768, 127)
end

----------------------

local package = {}
for k, v in pairs(polyfill) do
  package[k] = v
end
for k, v in pairs(packageMetadata) do
  package[k] = v
end
return package

----------------------
