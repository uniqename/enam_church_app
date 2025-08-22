import React from 'react';
import ReactDOM from 'react-dom/client';
import './App.css';
import App from './App';
import TestApp from './TestApp';
import SimpleApp from './SimpleApp';
import EnhancedApp from './EnhancedApp';

const root = ReactDOM.createRoot(document.getElementById('root'));
// Use EnhancedApp with full functionality
root.render(<EnhancedApp />);