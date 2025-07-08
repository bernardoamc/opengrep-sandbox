import * as React from 'react';
import * as DOMPurify from 'dompurify';

const bar = ['bar'];
const foobar = {foo: 'bar'};

const TestBadDangerousHTML = (param) => {
  return (
    // nosemgrep: no-react-dangerouslysetinnerhtml
    <div dangerouslySetInnerHTML={{__html: param}}></div>
  );
};

const TestSanitized = () => {
  return (
    <div
      // ok: no-react-dangerouslysetinnerhtml
      dangerouslySetInnerHTML={{__html: DOMPurify.sanitize('Hello World')}}
    ></div>
  );
};

const TestBadDangerousHTMLInHash = (param) => {
  // nosemgrep: no-react-dangerouslysetinnerhtml
  let params = {smth: 'test123', dangerouslySetInnerHTML: {__html: param}};
  return React.createElement('div', params);
};

const TestSanitizedDangerousHTMLInHash = () => {
  let params = {
    smth: 'test123',
    // ok: no-react-dangerouslysetinnerhtml
    dangerouslySetInnerHTML: {__html: DOMPurify.sanitize('foobar')},
  };
  return React.createElement('div', params);
};

const TestBadDangerousHTMLInGlobalArray = () => {
  return (
    // nosemgrep: no-react-dangerouslysetinnerhtml
    <div dangerouslySetInnerHTML={{__html: bar[0]}}></div>
  );
};

const TestBadDangerousHTMLInGlobalObject = () => {
  return (
    // nosemgrep: no-react-dangerouslysetinnerhtml
    <div dangerouslySetInnerHTML={{__html: foobar.foo}}></div>
  );
};
