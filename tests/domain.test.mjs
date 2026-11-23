import {test} from 'node:test';import assert from 'node:assert/strict';import {validateProfile,normalizePhone,money} from '../src/domain.mjs';
test('reject invalid profile and accept Brazilian contact',()=>{assert.ok(validateProfile('A','41999999999'));assert.ok(validateProfile('Nome de teste','123'));assert.equal(validateProfile('Nome de teste','(41) 99999-9999'),null);assert.equal(normalizePhone('(41) 99999-9999'),'41999999999')});
test('format exact integer cent values',()=>{assert.equal(money(5990).replace(/\s/g,''),'R$59,90');assert.equal(money(13990).replace(/\s/g,''),'R$139,90')});
