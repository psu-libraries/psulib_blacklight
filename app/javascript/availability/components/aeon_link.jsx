import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import availability from '../index.js';
import Spinner from './spinner.jsx';

const AeonLink = ({holding, locationText}) => {
    const [url, setUrl] = useState('#');
    const [showSpinner, setShowSpinner] = useState(true);

    useEffect(() => {
        createAeonUrl();
    }, []);

    const createAeonUrl = () => {
        const catkey = holding.catkey;
        const callNumber = encodeURIComponent(holding.callNumber);
        const itemLocation = encodeURIComponent(locationText);
        const itemID = encodeURIComponent(holding.itemID);
        const itemTypeID = holding.itemTypeID;
        const genre = itemTypeID === "ARCHIVES" ? "ARCHIVES" : "BOOK";
        let aeonUrl = `https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30` +
            `&ReferenceNumber=${catkey}&Genre=${genre}&Location=${itemLocation}` +
            `&ItemNumber=${itemID}&CallNumber=${callNumber}`;

        $.get(`/catalog/${catkey}/raw.json`).then((data) => {
            if (Object.keys(data).length > 0) {
                const title = encodeURIComponent(data.title_245ab_tsim);
                const author = encodeURIComponent(data.author_tsim ? data.author_tsim : "");
                const publisher = encodeURIComponent(data.publisher_name_ssm ? data.publisher_name_ssm : "");
                const pubDate = encodeURIComponent(data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "");
                const pubPlace = encodeURIComponent(data.publication_place_ssm ? data.publication_place_ssm : "");
                const edition = encodeURIComponent(data.edition_display_ssm ? data.edition_display_ssm : "");
                const restrictions = encodeURIComponent(
                    data.restrictions_access_note_ssm ? data.restrictions_access_note_ssm : ""
                );
                const subLocation = encodeURIComponent(data.sublocation_ssm ? data.sublocation_ssm.join("; ") : "");
                aeonUrl += `&ItemTitle=${title}&ItemAuthor=${author}&ItemEdition=${edition}&ItemPublisher=` +
                    `${publisher}&ItemPlace=${pubPlace}&ItemDate=${pubDate}&ItemInfo1=${restrictions}` +
                    `&SubLocation=${subLocation}`;
            }

            setShowSpinner(false);
            setUrl(aeonUrl);
        });
    };

    const label = () => {
        return availability.isArchivalThesis(holding) ? 'View in Special Collections' : 'Request Material';
    };

    return (
        <a href={url}>
            <Spinner isVisible={showSpinner} />

            {label()}
        </a>
    );
};

// eslint-react: defines valid prop types passed to this component
AeonLink.propTypes = {
    holding: PropTypes.object,
    locationText: PropTypes.string
};

export default AeonLink;
